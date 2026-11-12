import Foundation

private typealias P = MockPeople
private typealias C = MockClock

// MARK: - Waiting on others

extension MockThreads {
    /// Customers, vendors and advisers who have committed to a reply or a deliverable.
    static var waitingPartners: [MailThread] {
        [
            thread("fab-8d", "RE: Root cause report for the RC2 crash", bucket: .waiting,
                   oneLiner: "Lydia's root cause report on the RC2 crash was due \(C.wd(-2)) and hasn't arrived.",
                   stands: "Fabrikam triaged the preview-cache crash quickly, and Lydia committed to the full root cause report by \(C.wd(-2)). It's overdue. Your quality team can't close the issue without it.",
                   replies: ["Hi Lydia, any update on the report?", "Can you send what you have so far?"],
                   messages: [
                    (P.me, 150, "Lydia, thanks for the quick triage. Can you send the full root cause report so we can close this out with our quality team?"),
                    (P.lydia, 148, "Of course. I'll send the full root cause report by \(C.wd(-2))."),
                   ]),
            thread("aw-sitedata", "Site-level pilot data", bucket: .waiting,
                   oneLiner: "Kristin will send pilot usage by site by \(C.wd(1)).",
                   stands: "You asked Adventure Works for usage broken out by site so the leadership slide can show the canyon locations separately. Kristin committed to it by \(C.wd(1)).",
                   replies: ["Thanks Kristin!", "A CSV is fine if that's quicker."],
                   messages: [
                    (P.me, 21, "Kristin, could you share the pilot usage broken out by site? I'd like to show the canyon locations separately."),
                    (P.kristin, 19, "Sure thing. I'll pull the export and send it by \(C.wd(1))."),
                   ]),
            thread("woodgrove-terms", "S/MIME requirements: revised list", bucket: .waiting,
                   oneLiner: "Woodgrove will issue its revised S/MIME requirements by \(C.wd(3)).",
                   stands: "You told Woodgrove Bank that certificate delivery through Intune is supported but hardware tokens are not in this release. Robert agreed in principle and committed to a revised requirements list by \(C.wd(3)).",
                   messages: [
                    (P.me, 44, "Robert, thanks for the call. As discussed, we support automated certificate delivery through Intune, but not the hardware-token requirement in this release."),
                    (P.robert, 42, "Understood, and I think we can get there. We'll issue the revised requirements by \(C.wd(3))."),
                   ]),
            thread("freight", "Localization quote: 24 or 38 languages for What's New", bucket: .waiting,
                   oneLiner: "Daichi's quotes for 24 and 38 languages were due \(C.wd(-1)). Still waiting.",
                   stands: "You need both quotes to decide how many languages the What's New screens ship in. Daichi committed to them by \(C.wd(-1)) and they haven't arrived. The RC3 decision makes this more urgent.",
                   replies: ["Hi Daichi, are the quotes ready?", "The 24-language quote alone is fine for now."],
                   messages: [
                    (P.me, 80, "Daichi, we may lose four days in testing. Can you quote both 24 and 38 languages for the What's New screens so we can compare?"),
                    (P.daichi, 77, "Yes. I'll send both quotes by \(C.wd(-1))."),
                   ]),
            thread("proseware-estimate", "Scope change: App Store screenshots", bucket: .waiting,
                   oneLiner: "Miguel's revised Proseware estimate was due \(C.wd(-2)).",
                   stands: "You added App Store screenshots to the launch scope. Miguel said he'd send a revised estimate by \(C.wd(-2)). It's overdue, and the SOW can't be amended without it.",
                   replies: ["Miguel, can you send the revised estimate today?", "A ballpark figure is fine for now."],
                   messages: [
                    (P.me, 125, "Miguel, we'd like to add App Store screenshots to the scope: 12 screens, light and dark. What does that do to the estimate?"),
                    (P.miguel, 122, "Easy to add. I'll send the revised estimate by \(C.wd(-2))."),
                   ]),
            thread("designer-search", "Principal Designer search: shortlist", bucket: .waiting,
                   oneLiner: "First Up will send a shortlist of five designers by \(C.md(5)).",
                   stands: "The search kicked off last week. Johnie has 14 people in conversation and committed to a shortlist of five by \(C.md(5)).",
                   messages: [
                    (P.me, 100, "Johnie, the profile looks right. Mobile experience matters more to us than agency polish."),
                    (P.johnie, 98, "Noted. I have 14 people in conversation now. You'll have a shortlist of five by \(C.md(5))."),
                   ]),
            thread("datum-revrec", "Accessibility audit of the new calendar", bucket: .waiting,
                   oneLiner: "A. Datum will send its accessibility findings on the new calendar by \(C.md(6)).",
                   stands: "Drag to reschedule changes how the calendar works with VoiceOver and TalkBack. Laurence's team is auditing it and will respond by \(C.md(6)). The release review needs their findings.",
                   messages: [
                    (P.me, 70, "Laurence, attached are the builds with drag to reschedule. We need to know where VoiceOver and TalkBack fall short before the release review."),
                    (P.laurence, 66, "Thank you, Vivek. We'll review with our technical team and revert with our findings by \(C.md(6))."),
                   ]),
            thread("liability-cert", "Humongous Insurance pilot: countersigned agreement", bucket: .waiting,
                   oneLiner: "Humongous Insurance will send the countersigned pilot agreement by \(C.wd(2)).",
                   stands: "Voice catch-up can't be turned on for Humongous Insurance until the pilot agreement is countersigned. Bryan confirmed their legal team approved it and will send it by \(C.wd(2)).",
                   messages: [
                    (P.me, 31, "Bryan, we need the countersigned pilot agreement before we can turn on voice catch-up for your tenant. Can you send it?"),
                    (P.bryan, 29, "Yes, legal has approved it. The countersigned agreement will be issued by \(C.wd(2))."),
                   ]),
            thread("vanarsdel-accessories", "Partnership idea: boarding passes in the calendar", bucket: .waiting,
                   oneLiner: "Beth will come back after Blue Yonder's planning meeting. No date.",
                   stands: "You proposed that Blue Yonder Airlines supply boarding passes and gate changes for flights in the Outlook calendar. Beth liked it and said she'd get back to you after their planning meeting. She didn't give a date.",
                   messages: [
                    (P.me, 170, "Beth, our customers keep asking for boarding passes and gate changes next to the flight in their calendar. You have the best data for it. Would a joint feature be interesting?"),
                    (P.beth, 165, "It might be. Our own app competes for that screen, but reach matters to us. I'll get back to you after our planning meeting."),
                   ]),
            thread("nw-questionnaire", "Northwind security questionnaire (214 questions)", bucket: .waiting, attachment: true,
                   oneLiner: "You sent the completed questionnaire. Northwind's review ends around \(C.md(7)).",
                   stands: "You returned all 214 answers with Kevin's help. Hillary said the review takes about 10 business days and that she'd send follow-ups by \(C.md(7)).",
                   messages: [
                    (P.hillary, 130, "Vivek, attached is our vendor security questionnaire. It needs to be complete before the pilot agreement can be signed."),
                    (P.me, 76, "Hillary, the completed questionnaire is attached, along with our latest compliance reports. Kevin Sturgis on our security team can answer anything technical."),
                    (P.hillary, 74, "Thank you. Our review takes about 10 business days. I'll send any follow-up questions by \(C.md(7))."),
                   ]),
        ]
    }

    /// Colleagues who have committed to a number, a file or an answer.
    static var waitingInternal: [MailThread] {
        [
            thread("unit-cost", "Revised cost-per-user model for voice", bucket: .waiting,
                   oneLiner: "Pradeep's revised cost model was due \(C.wd(-1)). The leadership slide needs it.",
                   stands: "The adoption forecast slide for the leadership review depends on Pradeep's revised cost-per-user model for voice catch-up. He committed to it by \(C.wd(-1)) and it hasn't come.",
                   replies: ["Pradeep, can I get it this morning?", "Even a draft would help."],
                   messages: [
                    (P.me, 75, "Pradeep, can you rerun the cost-per-user model for voice catch-up with RC3's smaller speech model and the new usage assumption?"),
                    (P.pradeep, 73, "Yes. I'll get you the revised cost model by \(C.wd(-1))."),
                   ]),
            thread("mkt-number", "Marketing line for FY27", bucket: .waiting,
                   oneLiner: "Megan will send the final FY27 marketing number today.",
                   stands: "Your budget submission is due \(C.wd(1)) and needs Megan's launch marketing figure. She said she'd send it today, after her review with Miriam.",
                   replies: ["Thanks Megan. Budget is due tomorrow.", "A range works if it isn't final."],
                   messages: [
                    (P.me, 25, "Megan, Emily needs my budget by \(C.wd(1)). What's the final number for launch marketing?"),
                    (P.megan, 23, "I'm reviewing it with Miriam this afternoon. I'll send you the final number by end of day \(C.wd(0))."),
                   ]),
            thread("dashboard", "Release dashboard in Power BI", bucket: .waiting,
                   oneLiner: "Daisy's release dashboard link was due \(C.wd(-3)).",
                   stands: "You asked for one dashboard with ring adoption, pilot health and support tickets. Daisy committed to a link by \(C.wd(-3)). Nothing yet, and you want to show it at the release review.",
                   replies: ["Hi Daisy, how's the dashboard coming?", "Happy to look at a rough version."],
                   messages: [
                    (P.me, 190, "Daisy, for the release review I'd love one dashboard: ring adoption, pilot health and support tickets in one place."),
                    (P.daisy, 186, "Doable. I'll share the release dashboard link by \(C.wd(-3))."),
                   ]),
            thread("trademark", "Sandpiper feature names: clearance in the EU and Japan", bucket: .waiting,
                   oneLiner: "Enrico will confirm the EU clearance date by \(C.wd(4)).",
                   stands: "The feature names are cleared in the US and Japan. For the EU, outside counsel is finishing the search, and Enrico will confirm the clearance date by \(C.wd(4)).",
                   messages: [
                    (P.me, 90, "Enrico, where are we on clearing the feature names for the EU and Japan? Kayo is asking."),
                    (P.enrico, 88, "Japan is cleared. For the EU, outside counsel is finishing the search. I'll confirm the EU clearance date by \(C.wd(4))."),
                   ]),
            thread("packaging", "What's New art v3", bucket: .waiting,
                   oneLiner: "Grady will send the What's New art v3 by \(C.wd(1)).",
                   stands: "You asked for a simpler illustration and no gradient on the badge. Grady is on v3 and committed to renders by \(C.wd(1)).",
                   replies: ["Can't wait to see them.", "Please include the dark mode versions."],
                   messages: [
                    (P.me, 52, "Grady, v2 is close. Can we simplify the illustration and drop the gradient on the badge?"),
                    (P.grady, 50, "Yes to both. I'll have v3 renders to you by \(C.wd(1))."),
                   ]),
            thread("shared-channel", "Access request: shared channel with Northwind", bucket: .waiting,
                   oneLiner: "Allan will set up the Northwind shared channel by \(C.wd(1)).",
                   stands: "You asked for a shared Teams channel with Northwind's rollout team. Allan is waiting on a compliance check and expects to finish by \(C.wd(1)).",
                   messages: [
                    (P.me, 34, "Allan, can we get a shared channel with Northwind's rollout team? About 12 people on their side."),
                    (P.allan, 32, "Yes, once compliance clears their tenant. I'll have the shared channel provisioned by \(C.wd(1))."),
                   ]),
            thread("headcount-fse", "Headcount request: Customer Engineer", bucket: .waiting,
                   oneLiner: "Diego takes your Customer Engineer request to the comp committee on \(C.wd(2)).",
                   stands: "You asked for one extra hire to support the Northwind rollout. Diego will present it to the comp committee on \(C.wd(2)) and confirm afterwards.",
                   messages: [
                    (P.me, 58, "Diego, with Northwind likely to sign, I need a Customer Engineer in seat before March. The justification is attached."),
                    (P.diego, 55, "Makes sense. I'll take it to the comp committee and confirm the outcome by \(C.wd(2))."),
                   ]),
            thread("research-synthesis", "Frontline interviews: synthesis", bucket: .waiting,
                   oneLiner: "Mona's interview synthesis deck is due \(C.wd(3)).",
                   stands: "Mona finished 18 interviews with frontline workers. She's writing up the findings and committed to the deck by \(C.wd(3)).",
                   messages: [
                    (P.me, 64, "Mona, thanks for getting through all 18 interviews. When can we see the themes?"),
                    (P.mona, 62, "Still coding the transcripts. The synthesis deck will be ready by \(C.wd(3))."),
                   ]),
            thread("capex-fixtures", "Capex request: device lab ($310K)", bucket: .waiting, attachment: true,
                   oneLiner: "Carlos is reviewing the $310K device lab request with Emily. No date.",
                   stands: "You asked for $310K in capex for 120 more test devices in the lab. Carlos said he'd review it with Emily and come back to you this week, without naming a day.",
                   replies: ["Thanks Carlos. Happy to walk through it.", "Lee can join if you have questions on coverage."],
                   messages: [
                    (P.me, 60, "Carlos, attached is the capex request for 120 more test devices in the lab. They take us from 900 to 1,500 test runs a day."),
                    (P.carlos, 57, "Thanks. Let me review it with Emily and I'll come back to you this week."),
                   ]),
            thread("dock-capacity", "Rollout ring capacity for Sandpiper", bucket: .waiting,
                   oneLiner: "Nestor will confirm ring capacity for the first production wave by \(C.wd(1)).",
                   stands: "The first production wave covers 14 regions. Nestor is checking whether live site can take them in one week and will confirm by \(C.wd(1)).",
                   messages: [
                    (P.me, 38, "Nestor, the first production wave is 14 regions. Can live site take them in one week, or do we need to stagger?"),
                    (P.nestor, 35, "Tight but possible. I'll confirm ring capacity by \(C.wd(1))."),
                   ]),
            thread("cert-status", "Accessibility conformance report status", bucket: .waiting,
                   oneLiner: "The lab's final conformance report is due \(C.md(5)). Tim will forward it.",
                   stands: "The second conformance run passed with two minor notes. The lab is writing the final report, due \(C.md(5)), and Tim will forward it when it lands. It's one of the release review items.",
                   messages: [
                    (P.me, 46, "Tim, did the second conformance run pass?"),
                    (P.tim, 43, "It passed with two minor notes. The lab is writing it up now. I'll forward the final report by \(C.md(5))."),
                   ]),
        ]
    }
}
