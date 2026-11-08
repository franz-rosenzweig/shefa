import 'dart:io';

import 'package:chopper/chopper.dart' show Response;
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waterflyiii/auth.dart';
import 'package:waterflyiii/generated/swagger_fireflyiii_api/firefly_iii.swagger.dart';
import 'package:waterflyiii/pages/navigation.dart';
import 'package:waterflyiii/pages/transaction.dart';
import 'package:waterflyiii/widgets/fabs.dart';
import 'package:webview_flutter/webview_flutter.dart';

final Logger log = Logger("Pages.Record");

/// The Record (Jerrold Mundis's Spending Record and Spending Plan), added by
/// this fork. It is the Record page of the Firefly fork at
/// github.com/franz-rosenzweig/firefly-iii, opened from api/v1/record/app with
/// the app's own API token, so there is no second login and the page changes
/// without a new build. A charge opens here as a transaction; every other link
/// into Firefly opens in the browser.
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final Logger log = Logger("Pages.Record.Page");

  static final RegExp _transaction = RegExp(r'/transactions/show/(\d+)$');

  late final WebViewController _web;
  Brightness? _shown;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onNavigationRequest: _navigate,
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavPageElements>().appBarActions = <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Reload',
          onPressed: () => setState(_load),
        ),
      ];
      context.read<NavPageElements>().fab = NewTransactionFab(context: context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The page is drawn in the app's light or dark, so it is loaded again when
    // that changes.
    final Brightness brightness = Theme.of(context).brightness;
    if (brightness != _shown) {
      _shown = brightness;
      _web.setBackgroundColor(Theme.of(context).colorScheme.surface);
      _load();
    }
  }

  void _load() {
    final AuthUser? user = context.read<FireflyService>().user;
    if (user == null) {
      return;
    }
    // The page sends the token from after the # with everything it asks for;
    // the part after the # never leaves the phone.
    final Map<String, String> headers = Map<String, String>.of(user.headers())
      ..remove(HttpHeaders.acceptHeader);
    final String api = user.host.toString().replaceAll(RegExp(r'/+$'), '');
    final Uri page = Uri.parse('$api/v1/record/app').replace(
      queryParameters: <String, String>{
        'theme': _shown == Brightness.dark ? 'dark' : 'light',
      },
      fragment: 'auth=${headers[HttpHeaders.authorizationHeader] ?? ''}',
    );
    log.fine(() => "loading ${page.replace(fragment: '')}");
    _loading = true;
    _web.loadRequest(page, headers: headers);
  }

  NavigationDecision _navigate(NavigationRequest request) {
    final Uri uri = Uri.parse(request.url);
    if (!request.isMainFrame || uri.path.endsWith('/api/v1/record/app')) {
      return NavigationDecision.navigate;
    }
    final RegExpMatch? transaction = _transaction.firstMatch(uri.path);
    if (transaction != null) {
      _openTransaction(transaction.group(1)!);
    } else {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    return NavigationDecision.prevent;
  }

  Future<void> _openTransaction(String id) async {
    final FireflyIii api = context.read<FireflyService>().api;
    final Future<TransactionRead> transaction = api
        .v1TransactionsIdGet(id: id)
        .then((Response<TransactionSingle> response) {
          apiThrowErrorIfEmpty(response, null);
          return response.body!.data;
        });

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => FutureBuilder<TransactionRead>(
          future: transaction,
          builder:
              (BuildContext context, AsyncSnapshot<TransactionRead> snapshot) {
                if (snapshot.hasData) {
                  return TransactionPage(transaction: snapshot.data);
                }
                if (snapshot.hasError) {
                  return Scaffold(
                    appBar: AppBar(),
                    body: Center(child: Text(snapshot.error.toString())),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()),
                );
              },
        ),
      ),
    );
    // The charge may have been changed or deleted; the page asks for a fresh
    // copy and redraws when it lands.
    await _web.runJavaScript('window.recordRefresh && window.recordRefresh()');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        WebViewWidget(controller: _web),
        if (_loading) const LinearProgressIndicator(),
      ],
    );
  }
}
