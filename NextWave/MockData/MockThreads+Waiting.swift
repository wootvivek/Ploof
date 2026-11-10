import Foundation

private typealias P = MockPeople
private typealias C = MockClock

// MARK: - Waiting on others

extension MockThreads {
    /// Customers, suppliers and advisers who have committed to a reply or a deliverable.
    static var waitingPartners: [MailThread] {
        [
            thread("fab-8d", "RE: Corrective action for lot 2231", bucket: .waiting,
                   oneLiner: "Lydia's 8D report on the battery weld was due \(C.wd(-2)) and hasn't arrived.",
                   stands: "Fabrikam contained the weld problem quickly, and Lydia committed to the full 8D report by \(C.wd(-2)). It's overdue. Your quality team can't close the issue without it.",
                   replies: ["Hi Lydia, any update on the 8D?", "Can you send what you have so far?"],
                   messages: [
                    (P.me, 150, "Lydia, thanks for the quick containment. Can you send the full 8D report so we can close this out with our quality team?"),
                    (P.lydia, 148, "Of course. I'll send the full 8D report by \(C.wd(-2))."),
                   ]),
            thread("aw-sitedata", "Site-level uptime data", bucket: .waiting,
                   oneLiner: "Kristin will send uptime by site by \(C.wd(1)).",
                   stands: "You asked Adventure Works for uptime broken out by site so the board slide can show the canyon locations separately. Kristin committed to it by \(C.wd(1)).",
                   replies: ["Thanks Kristin!", "A CSV is fine if that's quicker."],
                   messages: [
                    (P.me, 21, "Kristin, could you share the pilot uptime broken out by site? I'd like to show the canyon locations separately."),
                    (P.kristin, 19, "Sure thing. I'll pull the export and send it by \(C.wd(1))."),
                   ]),
            thread("woodgrove-terms", "Equipment financing: revised terms", bucket: .waiting,
                   oneLiner: "Woodgrove will issue a revised term sheet for the test-fixture financing by \(C.wd(3)).",
                   stands: "You and Carlos asked Woodgrove to remove the prepayment penalty. Robert agreed in principle and committed to a revised term sheet by \(C.wd(3)).",
                   messages: [
                    (P.me, 44, "Robert, thanks for the call. As discussed, we'd like the prepayment penalty removed and the term extended to 48 months."),
                    (P.robert, 42, "Understood, and I think we can get there. We'll issue the revised term sheet by \(C.wd(3))."),
                   ]),
            thread("freight", "Freight quote: ocean or air for the first 4,000 units", bucket: .waiting,
                   oneLiner: "Daichi's ocean and air quotes were due \(C.wd(-1)). Still waiting.",
                   stands: "You need both quotes to decide how the first 4,000 units ship. Daichi committed to them by \(C.wd(-1)) and they haven't arrived. The Rev C decision makes this more urgent.",
                   replies: ["Hi Daichi, are the quotes ready?", "Air only is fine for now."],
                   messages: [
                    (P.me, 80, "Daichi, we may lose four days at the factory. Can you quote both ocean and air for the first 4,000 units so we can compare?"),
                    (P.daichi, 77, "Yes. I'll send both quotes by \(C.wd(-1))."),
                   ]),
            thread("proseware-estimate", "Scope change: retail kit photography", bucket: .waiting,
                   oneLiner: "Miguel's revised Proseware estimate was due \(C.wd(-2)).",
                   stands: "You added retail kit photography to the launch scope. Miguel said he'd send a revised estimate by \(C.wd(-2)). It's late, and the SOW can't be amended without it.",
                   replies: ["Miguel, can you send the revised estimate today?", "A ballpark figure is fine for now."],
                   messages: [
                    (P.me, 125, "Miguel, we'd like to add photography for the retail kit: 12 hero shots, white background. What does that do to the estimate?"),
                    (P.miguel, 122, "Easy to add. I'll send the revised estimate by \(C.wd(-2))."),
                   ]),
            thread("designer-search", "Principal Designer search: shortlist", bucket: .waiting,
                   oneLiner: "First Up will send a shortlist of five designers by \(C.md(5)).",
                   stands: "The search kicked off last week. Johnie has 14 people in conversation and committed to a shortlist of five by \(C.md(5)).",
                   messages: [
                    (P.me, 100, "Johnie, the profile looks right. Hardware experience matters more to us than agency polish."),
                    (P.johnie, 98, "Noted. I have 14 people in conversation now. You'll have a shortlist of five by \(C.md(5))."),
                   ]),
            thread("datum-revrec", "Revenue recognition for the bundled subscription", bucket: .waiting,
                   oneLiner: "A. Datum will give its position on bundle revenue recognition by \(C.md(6)).",
                   stands: "Pricing the Mark 8 with a bundled 12-month dashboard subscription changes how revenue is recognized. Laurence's team is reviewing and will respond by \(C.md(6)). The price list can't be final until then.",
                   messages: [
                    (P.me, 70, "Laurence, attached is the proposed bundle: hardware plus 12 months of the fleet dashboard at one price. We need to know how you'd expect us to recognize it."),
                    (P.laurence, 66, "Thank you, Vivek. We'll review with our technical team and revert with our position by \(C.md(6))."),
                   ]),
            thread("liability-cert", "Product liability: certificate for Northwind", bucket: .waiting,
                   oneLiner: "Humongous Insurance will issue the Northwind certificate by \(C.wd(2)).",
                   stands: "Northwind's contract requires a certificate of insurance naming them as additional insured. Bryan confirmed coverage and will issue the certificate by \(C.wd(2)).",
                   messages: [
                    (P.me, 31, "Bryan, Northwind Traders needs a certificate naming them as additional insured before signing. Can you issue one?"),
                    (P.bryan, 29, "Yes, coverage is in place. The certificate will be issued by \(C.wd(2))."),
                   ]),
            thread("vanarsdel-accessories", "Partnership idea: VanArsdel mounts for the Mark 8", bucket: .waiting,
                   oneLiner: "Beth will come back after VanArsdel's planning meeting. No date.",
                   stands: "You proposed that VanArsdel's accessory group build shelf and cart mounts for the Mark 8. Beth liked it and said she'd get back to you after their planning meeting. She didn't give a date.",
                   messages: [
                    (P.me, 170, "Beth, our customers keep asking for shelf and cart mounts. Your accessory team builds the best ones on the market. Would a co-branded line be interesting?"),
                    (P.beth, 165, "It might be. Our hardware group competes with you, but accessories is its own business. I'll get back to you after our planning meeting."),
                   ]),
            thread("nw-questionnaire", "Northwind security questionnaire (214 questions)", bucket: .waiting, attachment: true,
                   oneLiner: "You sent the completed questionnaire. Northwind's review ends around \(C.md(7)).",
                   stands: "You returned all 214 answers with Kevin's help. Hillary said the review takes about 10 business days and that she'd send follow-ups by \(C.md(7)).",
                   messages: [
                    (P.hillary, 130, "Vivek, attached is our vendor security questionnaire. It needs to be complete before the MSA can be signed."),
                    (P.me, 76, "Hillary, the completed questionnaire is attached, along with our latest SOC 2 report. Kevin Sturgis on our security team can answer anything technical."),
                    (P.hillary, 74, "Thank you. Our review takes about 10 business days. I'll send any follow-up questions by \(C.md(7))."),
                   ]),
        ]
    }

    /// Colleagues who have committed to a number, a file or an answer.
    static var waitingInternal: [MailThread] {
        [
            thread("unit-cost", "Revised unit cost model", bucket: .waiting,
                   oneLiner: "Pradeep's revised unit cost model was due \(C.wd(-1)). The board slide needs it.",
                   stands: "The unit forecast slide for the board depends on Pradeep's revised cost model with the Rev C battery. He committed to it by \(C.wd(-1)) and it hasn't come.",
                   replies: ["Pradeep, can I get it this morning?", "Even a draft would help."],
                   messages: [
                    (P.me, 75, "Pradeep, can you rerun the unit cost model with the Rev C battery price and the new freight assumption?"),
                    (P.pradeep, 73, "Yes. I'll get you the revised unit cost model by \(C.wd(-1))."),
                   ]),
            thread("mkt-number", "Marketing line for FY27", bucket: .waiting,
                   oneLiner: "Megan will send the final FY27 marketing number today.",
                   stands: "Your budget submission is due \(C.wd(1)) and needs Megan's launch marketing figure. She said she'd send it today, after her review with Miriam.",
                   replies: ["Thanks Megan. Budget is due tomorrow.", "A range works if it isn't final."],
                   messages: [
                    (P.me, 25, "Megan, Emily needs my budget by \(C.wd(1)). What's the final number for launch marketing?"),
                    (P.megan, 23, "I'm reviewing it with Miriam this afternoon. I'll send you the final number by end of day \(C.wd(0))."),
                   ]),
            thread("dashboard", "Launch dashboard in Power BI", bucket: .waiting,
                   oneLiner: "Daisy's launch dashboard link was due \(C.wd(-3)).",
                   stands: "You asked for one dashboard with pre-orders, pilot health and support tickets. Daisy committed to a link by \(C.wd(-3)). Nothing yet, and you want to show it at the launch gate.",
                   replies: ["Hi Daisy, how's the dashboard coming?", "Happy to look at a rough version."],
                   messages: [
                    (P.me, 190, "Daisy, for the launch gate I'd love one dashboard: pre-orders, pilot health and support tickets in one place."),
                    (P.daisy, 186, "Doable. I'll share the launch dashboard link by \(C.wd(-3))."),
                   ]),
            thread("trademark", "Mark 8 trademark filings: EU and Japan", bucket: .waiting,
                   oneLiner: "Enrico will confirm the EU filing date by \(C.wd(4)).",
                   stands: "The US mark is registered. The Japan application is filed. For the EU, outside counsel is finishing a clearance search, and Enrico will confirm the filing date by \(C.wd(4)).",
                   messages: [
                    (P.me, 90, "Enrico, where are we on the EU and Japan trademark filings? Kayo is asking."),
                    (P.enrico, 88, "Japan is filed. For the EU, outside counsel is finishing the clearance search. I'll confirm the EU filing date by \(C.wd(4))."),
                   ]),
            thread("packaging", "Packaging v3", bucket: .waiting,
                   oneLiner: "Grady will send packaging v3 renders by \(C.wd(1)).",
                   stands: "You asked for a smaller box and less plastic. Grady is on v3 and committed to renders by \(C.wd(1)).",
                   replies: ["Can't wait to see them.", "Please include the retail hang-tab version."],
                   messages: [
                    (P.me, 52, "Grady, v2 is close. Can we shrink the box by about 15% and drop the plastic tray?"),
                    (P.grady, 50, "Yes to both. I'll have v3 renders to you by \(C.wd(1))."),
                   ]),
            thread("shared-channel", "Access request: shared channel with Northwind", bucket: .waiting,
                   oneLiner: "Allan will set up the Northwind shared channel by \(C.wd(1)).",
                   stands: "You asked IT for a shared Teams channel with Northwind's rollout team. Allan is waiting on a compliance check and expects to finish by \(C.wd(1)).",
                   messages: [
                    (P.me, 34, "Allan, can we get a shared channel with Northwind's rollout team? About 12 people on their side."),
                    (P.allan, 32, "Yes, once compliance clears their tenant. I'll have the shared channel provisioned by \(C.wd(1))."),
                   ]),
            thread("headcount-fse", "Headcount request: Field Solutions Engineer", bucket: .waiting,
                   oneLiner: "Diego takes your Field Solutions Engineer request to the comp committee on \(C.wd(2)).",
                   stands: "You asked for one extra hire to support the Northwind rollout. Diego will present it to the comp committee on \(C.wd(2)) and confirm afterwards.",
                   messages: [
                    (P.me, 58, "Diego, with Northwind likely to sign, I need a Field Solutions Engineer in seat before March. The justification is attached."),
                    (P.diego, 55, "Makes sense. I'll take it to the comp committee and confirm the outcome by \(C.wd(2))."),
                   ]),
            thread("research-synthesis", "Store manager interviews: synthesis", bucket: .waiting,
                   oneLiner: "Mona's interview synthesis deck is due \(C.wd(3)).",
                   stands: "Mona finished 18 store manager interviews. She's writing up the findings and committed to the deck by \(C.wd(3)).",
                   messages: [
                    (P.me, 64, "Mona, thanks for getting through all 18 interviews. When can we see the themes?"),
                    (P.mona, 62, "Still coding the transcripts. The synthesis deck will be ready by \(C.wd(3))."),
                   ]),
            thread("capex-fixtures", "Capex request: test fixtures ($310K)", bucket: .waiting, attachment: true,
                   oneLiner: "Carlos is reviewing the $310K test-fixture request with Emily. No date.",
                   stands: "You asked for $310K in capex for two more end-of-line test fixtures. Carlos said he'd review it with Emily and come back to you this week, without naming a day.",
                   replies: ["Thanks Carlos. Happy to walk through it.", "Lee can join if you have questions on throughput."],
                   messages: [
                    (P.me, 60, "Carlos, attached is the capex request for two more end-of-line test fixtures. They take us from 900 to 1,500 units a day."),
                    (P.carlos, 57, "Thanks. Let me review it with Emily and I'll come back to you this week."),
                   ]),
            thread("dock-capacity", "Warehouse readiness for the Mark 8", bucket: .waiting,
                   oneLiner: "Nestor will confirm dock capacity for the first shipment by \(C.wd(1)).",
                   stands: "The first shipment is 14 containers. Nestor is checking whether the Tacoma warehouse can take them in one week and will confirm by \(C.wd(1)).",
                   messages: [
                    (P.me, 38, "Nestor, the first inbound is 14 containers. Can Tacoma take them in one week, or do we need to stagger?"),
                    (P.nestor, 35, "Tight but possible. I'll confirm dock capacity by \(C.wd(1))."),
                   ]),
            thread("cert-status", "FCC and CE certification status", bucket: .waiting,
                   oneLiner: "The lab's final certification report is due \(C.md(5)). Tim will forward it.",
                   stands: "Emissions testing passed on the second run. The lab is writing the final report, due \(C.md(5)), and Tim will forward it when it lands. It's one of the launch gate items.",
                   messages: [
                    (P.me, 46, "Tim, did the second emissions run pass?"),
                    (P.tim, 43, "It passed with 4 dB of margin. The lab is writing it up now. I'll forward the final report by \(C.md(5))."),
                   ]),
        ]
    }
}
