# Shefa

Shefa (שֶׁפַע, "abundance") is an Android app for [Firefly III](https://github.com/firefly-iii/firefly-iii) that brings in the tools from Jerrold Mundis's book *How to Get Out of Debt, Stay Out of Debt & Live Prosperously*, along with a few from his *Earn What You Deserve*. It's built on [Waterfly III](https://github.com/dreautall/waterfly-iii) by dreautall, so everything Waterfly does, Shefa does too: transactions, accounts, budgets, bills, piggy banks, charts, and turning bank notifications into new transactions.

## The book comes first

Everything that makes Shefa different comes from Jerrold Mundis. *How to Get Out of Debt, Stay Out of Debt & Live Prosperously* is where the Spending Record, the Spending Plan, the monthly sit-down, the contingency fund and the patient way of paying debts back all come from, and *Earn What You Deserve* does the same for the earning side, with the offer check and the idea of seeing what's left per hour instead of the gross. He writes without blame or shame, which is a big part of why it works. Shefa doesn't add anything to his method. It just does the arithmetic and keeps the pages for you, so the book is the REAL thing and the app is only a helper for it. If any of this is useful to you, please get his books and read them.

## The Record tab

What I added is a **Record** tab, right after the main page. It shows the month the way the book's Spending Record does, by calendar weeks (1–7, 8–14, 15–21, 22–end), with each day coloured by how the spending sat against the Spending Plan: green inside it, amber outside it, red past a line. Under that is every budget line with its Actual, Plan and (+) or (−). From the same tab you can sit down and make next month's Spending Plan the way the book's monthly session goes, see your debts with their Reduction Record, see your earnings by month and by client, and check an offer, which weighs what a job pays per hour after fees and tax against what you NEED per hour. Tapping a charge opens it as a normal transaction, so you can fix it right there.

The Record tab is a page that lives on the Firefly server rather than in the app, which means Shefa needs a Firefly III with that page added. That's my fork at [franz-rosenzweig/firefly-iii](https://github.com/franz-rosenzweig/firefly-iii), and its RECORD.md explains how the page works. The page draws numbers that a separate script works out from Firefly and writes to a file on the server. That script is built around one person's accounts, so it isn't public. The tab opens with the same API token Shefa logs in with, so there's no second login.

## Getting it

You can get Shefa from the [releases page](https://github.com/franz-rosenzweig/shefa/releases), built for arm64 phones, and [Obtainium](https://github.com/ImranR98/Obtainium) can follow it for updates. Shefa has its own app id (`xyz.tiresia.shefa`), which means it installs next to Waterfly III instead of over it. Each release is a Waterfly III release with my changes on top and is named after both, so `v1.3.0-r4` is Waterfly III 1.3.0 plus four Shefa commits. Basically, when Waterfly puts out a new version, Shefa follows within a week.

## Thanks

The method is Jerrold Mundis's, from the two books above, and Shefa wouldn't exist without them. The app itself is Waterfly III by dreautall and its contributors, under the MIT license, which Shefa keeps (see [LICENSE](../LICENSE)). Firefly III is by James Cole.
