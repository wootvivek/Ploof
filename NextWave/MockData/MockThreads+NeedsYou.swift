import Foundation

private typealias P = MockPeople
private typealias C = MockClock

// MARK: - Needs you

extension MockThreads {
    /// Customers, contracts and vendors waiting on a decision.
    static var needsYouDeals: [MailThread] {
        [
            thread("nw-escalation", "ESCALATION: Northwind store #412, 9 units offline", bucket: .needsYou, unread: true, flagged: true,
                   oneLiner: "Robin needs you to approve the Northwind outage note within the hour.",
                   stands: "Nine pilot units at Northwind store #412 went offline after the 2.3.1 firmware push. Engineering is rolling back and is 60% done. Robin is waiting on your approval of the customer note before it goes to Charlotte's team.",
                   replies: ["Approved. Send it.", "Soften the second paragraph, then send.", "Call me before it goes out."],
                   messages: [
                    (P.robin, 1.4, "Vivek, heads up before this reaches you another way. Nine Mark 8 pilot units at Northwind store #412 have been offline since last night, right after the 2.3.1 firmware push. Charlotte's team opened a Sev 2. Engineering is rolling back now. I need you to approve the customer note below within the hour so it reaches them before their morning stand-up.\n\nDraft: \"We identified a fault in firmware 2.3.1 that affects units on the older access points in store #412. We are rolling back now and expect all nine units online by 10 AM. A full review will follow within two business days.\""),
                    (P.colin, 0.8, "Rollback is 60% done. ETA 40 minutes for the remaining units. Root cause looks like the Wi-Fi roaming change, which we never tested on their older access points."),
                   ]),
            thread("nw-msa", "Northwind MSA: redlines v4, two items need your call", bucket: .needsYou, unread: true, attachment: true,
                   oneLiner: "Enrico needs your call on the liability cap and SLA credits by \(C.wd(1)).",
                   stands: "Northwind's counsel returned v4. Two business decisions are open: a liability cap of 2x annual fees (we offered 1x) and SLA credits of 10% per missed month. Enrico can hold the line on one, probably not both, and needs your answer by \(C.wd(1)) to keep the signing date.",
                   replies: ["Give on the cap, hold on credits.", "Hold both. I'll call Charlotte.", "Can we cap credits at 5%?"],
                   messages: [
                    (P.enrico, 20, "Vivek, Northwind's counsel came back on v4. Two items need a business decision. First, they want the liability cap at 2x annual fees, and we proposed 1x. Second, they want SLA credits of 10% for each month we miss the uptime target. I can hold the line on one of these but probably not both. I need your call by \(C.wd(1)) to keep the signing date."),
                    (P.joni, 6, "Adding the comparison table of v3 against v4 so the changes are easy to scan. Clause 9.2 and Schedule C are the two that matter. Everything else is agreed."),
                   ]),
            thread("nw-pricing", "RE: Mark 8 rollout: volume pricing for 1,200 stores", bucket: .needsYou, unread: true,
                   oneLiner: "Charlotte needs pricing at 5,000 and 8,000 units by \(C.wd(2)), now with a 3-year option.",
                   stands: "You committed to sending Charlotte pricing at both volume tiers by \(C.wd(2)), ahead of Northwind's steering committee on \(C.wd(3)). Her CFO has since asked for a 3-year term quote as well. Nothing has been sent yet.",
                   replies: ["Will include the 3-year term.", "Sending both tiers tomorrow.", "Can we walk through it live first?"],
                   messages: [
                    (P.isaiah, 50, "Charlotte, great meeting yesterday. Looping in Vivek, who owns the Mark 8 roadmap and can speak to the volume tiers."),
                    (P.charlotte, 47, "Thanks Isaiah. Vivek, our steering committee meets \(C.wd(3)). To take the 1,200-store rollout to them I need your best price at 5,000 and 8,000 units, and confirmation that the fleet dashboard is included. Can you send that by \(C.wd(2))?"),
                    (P.me, 45, "Hi Charlotte, absolutely. I'll send pricing at both tiers by \(C.wd(2)), and yes, the fleet dashboard is included at no extra cost."),
                    (P.charlotte, 4, "Perfect. One more ask from our CFO: can you also quote a 3-year term? Thanks."),
                   ]),
            thread("fab-revc", "Battery module yield: decision needed on Rev C", bucket: .needsYou, unread: true, flagged: true,
                   oneLiner: "Fabrikam can switch to Rev C on \(C.wd(2)) if you approve by \(C.wd(1)).",
                   stands: "Lot 2231 came in at 91.4% yield against a 96% target because of a weld on the tab connector. Rev C fixes it and adds four days to the build. Lee recommends taking it. Mauricio needs your written go-ahead by \(C.wd(1)), or the next window is three weeks out.",
                   replies: ["Go ahead with Rev C.", "Approved. Please confirm the new ship date.", "Can we split the lot?"],
                   messages: [
                    (P.lydia, 40, "Team, incoming inspection on lot 2231 shows yield at 91.4% against the 96% target. Root cause is the weld on the tab connector. Rev C fixes it but adds four days to the build."),
                    (P.lee, 30, "From manufacturing: I'd take Rev C. Shipping at 91% means rework on our line that costs us more than four days."),
                    (P.mauricio, 5, "Vivek, we can switch the line to Rev C starting \(C.wd(2)) if we get your written go-ahead by \(C.wd(1)). Otherwise the next window is three weeks out."),
                   ]),
            thread("aw-pilot", "Pilot results and next steps", bucket: .needsYou, unread: true, attachment: true,
                   oneLiner: "Adventure Works pilot: 99.2% uptime, 17% more jobs a day. Ray wants offline mode and a rugged case.",
                   stands: "The 9-week pilot went well: 38 units, 99.2% uptime, and technicians closed 17% more jobs per day. Before a full order Ray wants an answer on offline mode for the canyon sites and a rugged case option. Elvia has offered \(C.wd(2)) at 10 for the review.",
                   replies: ["\(C.wd(2)) at 10 works.", "Offline mode is planned for spring. Details on the call.", "Can Lidia join too?"],
                   messages: [
                    (P.ray, 22, "Vivek, pilot numbers are attached. Short version: 38 units in the field for 9 weeks, uptime 99.2%, and technicians closed 17% more jobs per day. Two asks before we talk about a full order: offline mode for the canyon sites, and a rugged case option. Can we get 30 minutes this week?"),
                    (P.elvia, 20, "Great results. Vivek, I can set this up. Are you free \(C.wd(2)) at 10?"),
                   ]),
            thread("litware", "Litware Analytics renewal: quote expires \(C.md(5))", bucket: .needsYou, attachment: true,
                   oneLiner: "Christie needs your seat count to negotiate the Litware renewal. Only 61 of 140 seats were active.",
                   stands: "Litware quoted a 12% uplift on the 3-year renewal, or 6% if signed before \(C.md(5)). Christie thinks she can get flat pricing, but needs to know how many of the 140 seats you want to keep. Usage shows 61 were active last quarter.",
                   replies: ["Let's cut to 80 seats.", "Keep 100. The field team starts in January.", "Can you send the usage report?"],
                   messages: [
                    (P.celeste, 70, "Hi Vivek, attached is the 3-year renewal for Litware Analytics. It reflects a 12% uplift, or 6% if you sign before \(C.md(5)). Happy to walk through it."),
                    (P.christie, 24, "Vivek, procurement can push for flat pricing, but I need to know if you're keeping all 140 seats. The usage report says 61 were active last quarter. How many do you actually need?"),
                   ]),
            thread("relecloud-pir", "Post-incident review: telemetry ingestion outage", bucket: .needsYou, unread: true, attachment: true,
                   oneLiner: "Relecloud offers an $18,400 credit for the 47-minute outage. Accept or counter by \(C.md(7)).",
                   stands: "Relecloud traced the 47-minute telemetry outage to an expired certificate on their side and proposes an $18,400 service credit. Johanna suggests also asking for certificate-expiry monitoring in the contract. They need your answer by \(C.md(7)).",
                   replies: ["Accept, and add cert monitoring to the contract.", "Counter at $25K.", "Johanna, can you draft the contract language?"],
                   messages: [
                    (P.henry, 18, "Vivek, Johanna, attached is our post-incident report for the 47-minute telemetry ingestion outage. The root cause was an expired certificate on our side. We're proposing a service credit of $18,400 and need you to accept or counter by \(C.md(7))."),
                    (P.johanna, 16, "The report is accurate. I'd ask them to add certificate-expiry monitoring to the contract, not just the credit."),
                   ]),
            thread("nda-wingtip", "NDA for Wingtip Toys: signature needed", bucket: .needsYou, attachment: true,
                   oneLiner: "Sign the Wingtip Toys NDA in Contoso eSign before their kickoff on \(C.wd(3)).",
                   stands: "The mutual NDA is ready and waiting on your signature. Wingtip won't share store data until it's countersigned, and their kickoff is \(C.wd(3)).",
                   replies: ["Signing now.", "Signed. Thanks Joni!", "Is this our standard template?"],
                   messages: [
                    (P.joni, 29, "Hi Vivek, the mutual NDA with Wingtip Toys is ready for your signature in Contoso eSign. Krystal's team won't share store data until it's countersigned, and their kickoff is \(C.wd(3)). Could you sign by then?"),
                   ]),
            thread("sow-southridge", "SOW approval: Southridge Video launch film ($86,000)", bucket: .needsYou, attachment: true,
                   oneLiner: "Approve the $86,000 launch film SOW today so Christie can route it to Carlos.",
                   stands: "Southridge quoted $86,000 for the 90-second launch film and three cut-downs, with half due at signing. It's over your $75K limit, so it needs you and then Carlos. Crew is on hold for the week of \(C.md(8)).",
                   replies: ["Approved.", "Approved. Please ask about dropping one cut-down.", "Need to check the marketing budget first."],
                   messages: [
                    (P.marie, 55, "Attached is the SOW for the 90-second launch film and three cut-downs. The total is $86,000, with 50% due at signing. We're holding crew for the week of \(C.md(8))."),
                    (P.christie, 8, "Vivek, this is over your $75K threshold, so it needs you and Carlos. If you approve today I can route it to Carlos tomorrow."),
                   ]),
            thread("tailspin-intro", "Intro: Will Little (Tailspin Toys) and Vivek", bucket: .needsYou,
                   oneLiner: "Will at Tailspin Toys wants a 45-minute Mark 8 demo next week. Send times.",
                   stands: "Miriam introduced you to Will, who runs merchandising at Tailspin Toys and is weighing a 300-store pilot. He asked for a demo next week, Tuesday or Wednesday afternoon, and is waiting on times.",
                   replies: ["Tuesday at 2 PM works.", "Wednesday at 3? I'll bring Lidia.", "Sending an invite now."],
                   messages: [
                    (P.miriam, 30, "Vivek, meet Will Little, who runs merchandising at Tailspin Toys. Will saw the Mark 8 at the retail expo and wants to understand what a 300-store pilot would take. I'll let you two connect."),
                    (P.will, 27, "Thanks Miriam. Vivek, could you do a 45-minute demo for my team next week? Tuesday or Wednesday afternoon is best for us."),
                   ]),
        ]
    }

    /// Launch work: board, budget, security, marketing.
    static var needsYouLaunch: [MailThread] {
        [
            thread("board-deck", "Board deck: Mark 8 section", bucket: .needsYou, unread: true, flagged: true, attachment: true,
                   oneLiner: "Patti needs your five-slide Mark 8 section today. The pre-read goes out tonight.",
                   stands: "You told Patti and Debra you'd deliver the Mark 8 section by end of day today. The board meets \(C.wd(2)) and the pre-read goes out tonight. Debra sent the new template and a five-slide limit.",
                   replies: ["On track. You'll have it by 4.", "Sending a draft in an hour.", "Can I have six slides?"],
                   messages: [
                    (P.patti, 30, "Vivek, the board meets \(C.wd(2)). I need your Mark 8 section, covering launch readiness, pilot results and the revised unit forecast, so Debra can assemble the pre-read. Can you get it to us by end of day \(C.wd(0))?"),
                    (P.me, 28, "Yes. I'll have the Mark 8 section to you and Debra by end of day \(C.wd(0)). I'm waiting on the final pilot numbers from Adventure Works."),
                    (P.debra, 1.6, "Morning Vivek, a reminder that the pre-read goes to the board tonight. Please use the new template (attached) and keep it to five slides."),
                   ]),
            thread("comp-brief", "Competitive brief on the VanArsdel V3?", bucket: .needsYou, unread: true,
                   oneLiner: "Miriam is still waiting on the VanArsdel brief you committed to. She presents \(C.wd(1)).",
                   stands: "You committed to sending Miriam a one-page brief on the VanArsdel V3 by \(C.wd(-1)), so it's overdue. She presents to the sales team \(C.wd(1)) and needs it for the objection-handling section.",
                   replies: ["Sorry Miriam, you'll have it by 3 today.", "Sending Babak's analysis now, brief to follow.", "Can Kat walk your team through it?"],
                   messages: [
                    (P.miriam, 96, "Vivek, the field keeps hearing about the VanArsdel V3 price cut. Could you put together a one-page competitive brief my reps can use?"),
                    (P.me, 94, "Sure. I'll get you the brief by \(C.wd(-1))."),
                    (P.miriam, 3, "Any update on this? I'm presenting to the sales team \(C.wd(1)) and I'd like it in the objection-handling section."),
                   ]),
            thread("ref-slide", "Reference slide for the Tailspin pitch", bucket: .needsYou,
                   oneLiner: "Isaiah needs the Adventure Works reference slide today for the Tailspin pitch.",
                   stands: "You told Isaiah you'd send the reference customer slide today. He's building the Tailspin Toys pitch tonight.",
                   replies: ["Sending it in 20 minutes.", "Use the pilot numbers Ray sent. Slide attached.", "Can it wait until tomorrow morning?"],
                   messages: [
                    (P.isaiah, 27, "Vivek, for the Tailspin pitch I'd love one slide on the Adventure Works pilot: the uptime number and the jobs-per-day lift. Do you have one?"),
                    (P.me, 26, "I'll send you the slide by end of day \(C.wd(0)), once Ray confirms the final numbers."),
                    (P.isaiah, 2.5, "Thanks! I'm building the deck tonight, so today works."),
                   ]),
            thread("budget-fy27", "FY27 budget: Mark 8 submission due \(C.wd(1))", bucket: .needsYou, unread: true, attachment: true,
                   oneLiner: "Submit FY27 headcount and program spend for cost center 4410 by \(C.wd(1)).",
                   stands: "Your cost center is one of three still outstanding. Finance locks the first pass on \(C.wd(1)). You can't finalize the marketing line until Megan sends her number, which she said she would send today.",
                   replies: ["Will submit tomorrow morning.", "Can I get one more day?", "Submitting today, with marketing as a placeholder."],
                   messages: [
                    (P.emily, 26, "Hi Vivek, FY27 budget templates are attached. Your cost center (4410, Mark 8 Product) is one of three still outstanding. Finance locks the first pass on \(C.wd(1)), so please submit headcount and program spend by then. The marketing line needs Megan's number before you can finalize."),
                   ]),
            thread("sec-review", "Mark 8 security review: 3 open findings", bucket: .needsYou, attachment: true,
                   oneLiner: "Kevin needs an owner and date for each of 3 pen-test findings by \(C.wd(2)).",
                   stands: "The pen test left one high and two medium findings open. Colin has taken the high one and committed to \(C.md(6)). Kevin can't sign the launch gate until all three have an owner and a date, and asked for them by \(C.wd(2)).",
                   replies: ["Colin has the high. I'll assign the other two today.", "Owners coming by tomorrow.", "Can the mediums wait for 2.4?"],
                   messages: [
                    (P.kevin, 33, "Vivek, the pen test report is attached. Three findings are open: one high (the firmware update isn't signature-checked on rollback) and two medium. I need a remediation owner and date for each before I can sign the launch gate. Can you reply with owners by \(C.wd(2))?"),
                    (P.colin, 31, "The high one is ours. The fix is in review and I can commit to \(C.md(6))."),
                   ]),
            thread("creative", "Launch campaign: pick a direction (A, B or C)", bucket: .needsYou, attachment: true,
                   oneLiner: "Pick a launch creative direction by \(C.wd(1)). Megan votes B.",
                   stands: "Proseware sent three directions: A 'Built for the floor', B 'One less thing', C 'The quiet upgrade'. Megan prefers B because it tested best with store managers. Proseware needs your pick by \(C.wd(1)) to hold the shoot dates.",
                   replies: ["Let's go with B.", "A for retail, B for field. Can we do both?", "Can I see B with the new product shots?"],
                   messages: [
                    (P.serena, 44, "Three creative directions for the Mark 8 launch are attached. A is 'Built for the floor', B is 'One less thing', and C is 'The quiet upgrade'. We need a pick by \(C.wd(1)) to hit the shoot dates with Southridge."),
                    (P.megan, 41, "My vote is B. It tests best with store managers in Trey's study. Vivek, your call."),
                   ]),
            thread("roadmap-h1", "Mark 8 H1 roadmap: comments by \(C.wd(1))?", bucket: .needsYou, attachment: true,
                   oneLiner: "Lidia wants your comments on the H1 roadmap by \(C.wd(1)), mainly on offline mode timing.",
                   stands: "Lidia's draft is in the team site. The open question is whether offline mode makes the March release or slips to May. She takes it to engineering on \(C.wd(2)) and wants your read first.",
                   replies: ["Will comment tonight.", "March, even if we cut scope.", "Let's talk at our 1:1."],
                   messages: [
                    (P.lidia, 12, "Hey Vivek, the H1 roadmap draft is in the team site. The big open question is whether offline mode makes the March release or slips to May. I need your read before I take it to engineering on \(C.wd(2)). Could you leave comments by \(C.wd(1))?"),
                   ]),
            thread("trey-readout", "Pricing study readout: pick a slot", bucket: .needsYou,
                   oneLiner: "Trey Research: buyers accept up to $349. Pick \(C.wd(2)) 2 PM or \(C.wd(3)) 11 AM for the readout.",
                   stands: "Fieldwork is done (412 store and field managers). Willingness to pay holds up to $349 and drops sharply above $379. Katri wants to walk you and Megan through the full results and offered two slots.",
                   replies: ["\(C.wd(2)) at 2 PM works.", "\(C.wd(3)) at 11, please.", "Can you send the deck ahead of time?"],
                   messages: [
                    (P.katri, 36, "Hi Vivek, fieldwork is complete (n=412 store and field managers). The headline: willingness to pay holds up to $349 and drops sharply above $379. I'd like to walk you and Megan through the full readout. Could you do \(C.wd(2)) at 2 PM or \(C.wd(3)) at 11 AM?"),
                   ]),
            thread("japan", "Japan launch timing: need a decision", bucket: .needsYou,
                   oneLiner: "Kayo needs a yes or no on a same-quarter Japan launch by \(C.md(6)) to book the Tokyo show.",
                   stands: "Japan's two largest distributors want to know if the Mark 8 ships there in the same quarter as the US. Certification is on track for March. Kayo needs your decision by \(C.md(6)) to book a stand at the Tokyo retail show.",
                   replies: ["Yes, book it.", "Not this quarter. Let's plan for summer.", "What does the stand cost?"],
                   messages: [
                    (P.kayo, 15, "Vivek-san, our two largest distributors are asking whether the Mark 8 will ship in Japan in the same quarter as the US. Certification is on track for March. If we want to announce at the Tokyo retail show, I need a yes or no from you by \(C.md(6)) to book the stand."),
                   ]),
            thread("press-lucerne", "Interview request: Lucerne Business Weekly on the Mark 8", bucket: .needsYou,
                   oneLiner: "Wanda recommends a 20-minute interview with Lucerne. Pick \(C.wd(2)) or \(C.wd(3)).",
                   stands: "A Lucerne reporter is writing about connected devices in retail and wants 20 minutes with you before launch. Wanda thinks it's friendly and fits the embargo. She needs a day from you and will prepare talking points.",
                   replies: ["\(C.wd(2)) afternoon works.", "\(C.wd(3)) morning, please.", "Can Megan take this one?"],
                   messages: [
                    (P.munger, 28, "Hi Wanda, I'm writing a piece on connected devices in retail and would love 20 minutes with Vivek ahead of the Mark 8 launch. My deadline is \(C.md(5))."),
                    (P.wanda, 25, "Vivek, I think we should do this one. It's friendly and the timing works with the embargo. Can you do 20 minutes \(C.wd(2)) or \(C.wd(3))? I'll prep talking points either way."),
                   ]),
        ]
    }

    /// People, approvals and admin.
    static var needsYouPeople: [MailThread] {
        [
            thread("offer-cameron", "Approval needed: Senior PM offer for Cameron Evans", bucket: .needsYou, unread: true,
                   oneLiner: "Approve Cameron Evans's offer by tomorrow. A competing offer expires \(C.wd(2)).",
                   stands: "The panel was unanimous. The offer is at the top of the L6 band with a sign-on bonus. Cameron's other offer expires \(C.wd(2)), so Amanda needs your approval in the hiring tool today or tomorrow.",
                   replies: ["Approved. Sending it through now.", "Can we talk comp for 10 minutes first?", "Approve, but hold the sign-on."],
                   messages: [
                    (P.amanda, 9, "Vivek, the panel was unanimous on Cameron Evans for the Senior PM role. The proposed offer is at the top of the L6 band with a sign-on bonus. Cameron has a competing offer that expires \(C.wd(2)), so I need your approval in the hiring tool today or tomorrow to get ours out in time."),
                   ]),
            thread("erik-1on1", "1:1 topics for \(C.wd(2))", bucket: .needsYou,
                   oneLiner: "Erik wants your one-page launch risk summary before your 1:1 on \(C.wd(2)).",
                   stands: "Erik plans to cover the launch gate, your headcount ask and the Northwind deal. He asked for a one-page launch risk summary ahead of the meeting and for any other topics.",
                   replies: ["Will send the one-pager tomorrow.", "Adding: Japan timing and the Rev C decision.", "Can we extend to 45 minutes?"],
                   messages: [
                    (P.erik, 10, "Vivek, for our 1:1 on \(C.wd(2)) I want to cover the Mark 8 launch gate, your headcount ask, and the Northwind deal. Please send me your one-page launch risk summary before the 1:1, plus anything else you want on the list."),
                   ]),
            thread("assessments", "Reminder: manager assessments due \(C.wd(3))", bucket: .needsYou,
                   oneLiner: "4 of your 6 year-end assessments are still in draft. Due \(C.wd(3)).",
                   stands: "Year-end assessments are due in the HR portal by \(C.wd(3)). You have four left in draft. Calibration is the week after, so the date can't move.",
                   replies: ["On it. They'll be in by \(C.wd(3)).", "Can I get the calibration schedule?"],
                   messages: [
                    (P.diego, 52, "Hi managers, year-end assessments are due in the HR portal by \(C.wd(3)). Vivek, you have 4 of 6 still in draft. Calibration is the following week, so there's no room to slip."),
                   ]),
            thread("offsite", "Leadership offsite: your session and logistics", bucket: .needsYou,
                   oneLiner: "Send Debra your offsite session title, AV needs and dietary notes by \(C.wd(3)).",
                   stands: "The leadership offsite is confirmed at Alpine Ski House, \(C.md(15)) to \(C.md(16)). You have the 45-minute 'Mark 8: the first 100 days' session. Debra needs your session title, AV needs and dietary restrictions by \(C.wd(3)).",
                   replies: ["Title: 'Mark 8: the first 100 days'. HDMI only, no restrictions.", "Will send by \(C.wd(3)).", "Can Lidia co-present?"],
                   messages: [
                    (P.debra, 48, "Hi all, the leadership offsite is confirmed at Alpine Ski House, \(C.md(15)) to \(C.md(16)). Vivek, you have the 45-minute 'Mark 8: the first 100 days' session. Please send me your session title, any AV needs and dietary restrictions by \(C.wd(3))."),
                   ]),
            thread("expense-lidia", "Approve: expense report from Lidia Holloway ($2,418.60)", bucket: .needsYou,
                   oneLiner: "Approve Lidia's $2,418.60 expo expenses. One hotel night is $42 over the cap.",
                   stands: "Lidia's report for the Chicago retail expo is waiting on you. Nine line items, one flagged: the hotel is $42 over the city cap. Approve or return it in Contoso Expenses.",
                   messages: [
                    (P.expenses, 7, "Lidia Holloway submitted the expense report 'Retail Expo, Chicago' for $2,418.60. It has 9 line items and 1 is flagged: the hotel exceeds the city cap by $42. Approve or return it in Contoso Expenses."),
                   ]),
            thread("laptop", "Action required: your laptop is due for replacement", bucket: .needsYou,
                   oneLiner: "Choose a replacement laptop and pickup slot in the IT portal by \(C.md(7)).",
                   stands: "Your laptop reaches end of support on \(C.md(14)). IT needs you to pick a model and a pickup slot by \(C.md(7)).",
                   messages: [
                    (P.itDesk, 54, "Your device (CONTOSO-LT-20418) reaches end of support on \(C.md(14)). Choose a replacement model and a pickup slot in the IT portal by \(C.md(7)). Your files sync automatically from OneDrive."),
                   ]),
            thread("bellows", "Guest lecture at Bellows College?", bucket: .needsYou,
                   oneLiner: "Bellows College invites you to give a 40-minute talk on \(C.md(17)) or \(C.md(22)).",
                   stands: "Professor Woodward asked whether you'd give a guest talk on bringing hardware to market to the product management seminar. Two dates are open. No reply yet.",
                   replies: ["Happy to. \(C.md(17)) works.", "I'd love to, but after launch. Spring term?", "Could Kat Larsson do it in my place?"],
                   messages: [
                    (P.elliot, 60, "Dear Vivek, I teach the product management seminar at Bellows College. Would you be willing to give a 40-minute guest talk on bringing hardware to market? We have openings on \(C.md(17)) and \(C.md(22)). The students would love to hear how the Mark 8 came together."),
                   ]),
        ]
    }
}
