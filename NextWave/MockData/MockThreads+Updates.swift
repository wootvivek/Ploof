import Foundation

private typealias P = MockPeople
private typealias C = MockClock

// MARK: - Updates (written by people, no action needed)

extension MockThreads {
    /// Release and customer news that needs no action.
    static var updatesLaunch: [MailThread] {
        [
            thread("launch-gate", "Sandpiper release review moved to \(C.md(9))", bucket: .updates, important: true, unread: true,
                   oneLiner: "The release review moved to \(C.md(9)) so the conformance report can be included.",
                   stands: "A date change only. The review moved two days so the final accessibility conformance report is in hand.",
                   messages: [
                    (P.irvin, 6, "Team, the Sandpiper release review moves to \(C.md(9)) so we have the final conformance report in hand. Same room, same attendees. Updated invite to follow."),
                   ]),
            thread("weekly-status", "Sandpiper weekly status report", bucket: .updates, important: true, attachment: true,
                   oneLiner: "Status: 2 green, 2 yellow (Android crash rate, security findings), 0 red.",
                   stands: "The weekly report. Android crash rate and the security findings are yellow, both already with you. Nothing new to act on.",
                   messages: [
                    (P.irvin, 28, "Weekly status is attached. Summary: iOS and the What's New screens are green. Android crash rate and the security findings are yellow. No reds. Preview ring sign-ups stand at 6,140 against a plan of 5,500."),
                   ]),
            thread("build-notes", "Build 4.2447 release notes", bucket: .updates, important: true,
                   oneLiner: "Build 4.2447 fixes the shared mailbox sync fault and goes to the preview ring \(C.wd(2)).",
                   stands: "Release notes for the fix to the Northwind sync fault. It goes to the preview ring on \(C.wd(2)) after a 48-hour soak.",
                   messages: [
                    (P.colin, 0.5, "4.2447 is built. It reverts the token refresh change and adds a test against conditional access policies. It goes to the preview ring on \(C.wd(2)) after a 48-hour soak."),
                   ]),
            thread("win-alpine", "WIN: Alpine Ski House standardizes on Outlook Mobile", bucket: .updates, important: true,
                   oneLiner: "Alpine Ski House is rolling out Outlook Mobile to 6,000 seasonal staff across four resorts.",
                   stands: "A customer win announcement. It's the first large hospitality rollout for the team.",
                   messages: [
                    (P.isaiah, 32, "Happy to share that Alpine Ski House is standardizing on Outlook Mobile for 6,000 seasonal staff across four resorts. It's our first large hospitality rollout. Thanks to Vivek's team for the demo support."),
                    (P.miriam, 31, "Great work, Isaiah. Hospitality wasn't on our list six months ago."),
                   ]),
            thread("customer-quote", "A customer quote you can use", bucket: .updates,
                   oneLiner: "An Adventure Works supervisor: 'I clear my inbox in the truck before the first job.'",
                   stands: "Elvia shared a quote from the pilot. It's approved for internal decks only.",
                   messages: [
                    (P.elvia, 49, "From one of the Adventure Works field supervisors, shared with permission for internal decks: 'I clear my inbox in the truck before the first job.' Thought you'd enjoy it."),
                   ]),
            thread("vanarsdel-v3", "VanArsdel announces Mail 3", bucket: .updates, attachment: true,
                   oneLiner: "VanArsdel Mail 3 adds AI triage for $8 a user per month, and only for its own mailboxes.",
                   stands: "Competitive news. Babak's analysis shows most enterprise customers already have the equivalent with the licenses they hold.",
                   messages: [
                    (P.babak, 98, "VanArsdel announced Mail 3 today with AI triage and a daily summary. It costs a separate $8 per user per month and works only with their own mailboxes. Most of our enterprise customers get the equivalent with licenses they already have. My analysis is attached."),
                   ]),
            thread("fab-po", "RE: Fabrikam Test Labs PO 88214 schedule", bucket: .updates,
                   oneLiner: "Christie and Mauricio agreed three device lab passes for PO 88214. You're on copy.",
                   stands: "A procurement thread you're copied on. Three lab passes are scheduled and will shift four days if RC3 is approved.",
                   messages: [
                    (P.christie, 41, "Mauricio, confirming PO 88214 for three device lab passes of 60 devices each."),
                    (P.mauricio, 39, "Confirmed. If RC3 is approved, each pass moves out four days. Copying Vivek for awareness."),
                   ]),
            thread("store-visits", "Store visit notes: Northwind #118 and #204", bucket: .updates, attachment: true,
                   oneLiner: "Adele's store visits: staff like the shared mailbox view, and sign-in at shift change takes too many taps.",
                   stands: "Field notes from two Northwind stores. The main finding is that signing in on a shared device at shift change is too slow.",
                   messages: [
                    (P.adele, 53, "Notes from two Northwind stores are attached. Staff picked up the shared mailbox view in a day. The one consistent complaint is sign-in on shared devices, which takes too many taps at shift change."),
                   ]),
            thread("supply-connectors", "Dependency update: notification quota raised", bucket: .updates,
                   oneLiner: "The push notification quota is raised ahead of the release.",
                   stands: "Good dependency news. The notification quota that worried the team is no longer a risk for the release.",
                   messages: [
                    (P.cecil, 67, "Good news from the notification service team: our quota is raised ahead of the release, and the lead time for further increases is down from 11 weeks to 6. That removes it from the release risk list."),
                   ]),
            thread("support-trends", "Support ticket trends: last month", bucket: .updates, attachment: true,
                   oneLiner: "Pilot support tickets fell 22%. Calendar sync conflicts are still the top issue.",
                   stands: "Robin's monthly support summary. Volume is down, and calendar sync conflicts remain the most common ticket.",
                   messages: [
                    (P.robin, 110, "Monthly summary attached. Pilot tickets are down 22% month over month. Calendar sync conflicts are still the top category at 31% of volume."),
                   ]),
            thread("comms-calendar", "Sandpiper comms calendar v2", bucket: .updates, attachment: true,
                   oneLiner: "Updated comms calendar: the embargo lifts at 6 AM Pacific on release day.",
                   stands: "The latest calendar from Marketing. Nothing changed on your items.",
                   messages: [
                    (P.alexW, 56, "Version 2 of the Sandpiper comms calendar is attached. The only change is the embargo time, which is now 6 AM Pacific on release day."),
                   ]),
            thread("patent", "Patent filed: adaptive voice summaries (ref CT-2291)", bucket: .updates,
                   oneLiner: "The adaptive voice summary patent application was filed. You're listed as a co-inventor.",
                   stands: "Legal filed the application. No action until the examiner responds, usually in 12 to 18 months.",
                   messages: [
                    (P.enrico, 140, "The adaptive voice summary application (our reference CT-2291) was filed yesterday. Vivek, Johanna and Grady are named as inventors. Nothing further is needed until the examiner responds, typically 12 to 18 months."),
                   ]),
            thread("design-crit", "Notes from design crit", bucket: .updates,
                   oneLiner: "Design crit notes: the drop target for drag to reschedule is too faint in bright light.",
                   stands: "Grady's notes from the design review. The team will test a stronger highlight next sprint.",
                   messages: [
                    (P.grady, 78, "Notes from crit: the drag-to-reschedule flow tested well. The drop target is too faint in bright light. We'll try a stronger highlight next sprint and report back."),
                   ]),
            thread("kayo-thanks", "Thank you for the roadmap session", bucket: .updates,
                   oneLiner: "Kayo says the Tokyo customers appreciated your roadmap walkthrough.",
                   stands: "A thank-you note. No action.",
                   messages: [
                    (P.kayo, 115, "Vivek-san, thank you for joining so late in your evening. Both customers said it was the clearest roadmap session they've had from us."),
                   ]),
        ]
    }

    /// Organization news, policy and announcements.
    static var updatesCompany: [MailThread] {
        [
            thread("org-update", "Organization update: Live Site and Partner Dependencies", bucket: .updates, important: true, unread: true,
                   oneLiner: "Partner Dependencies now reports to Nestor Wilke. Nothing changes for your team.",
                   stands: "An announcement from Patti. Cecil Folk's team moves under Nestor. Your team and reporting line are unchanged.",
                   messages: [
                    (P.patti, 14, "Team, effective the first of next month, Partner Dependencies will report to Nestor Wilke as part of Live Site. Cecil Folk continues to lead the team. This puts release operations, rollout and dependencies under one leader ahead of the Sandpiper ramp."),
                   ]),
            thread("board-inventory", "Leadership approved the preview ring expansion", bucket: .updates,
                   oneLiner: "Leadership approved expanding the Sandpiper preview ring to 20,000 users.",
                   stands: "Finance confirmed the approval. It covers the first two rollout waves.",
                   messages: [
                    (P.carlos, 160, "Leadership approved expanding the Sandpiper preview ring to 20,000 users by written consent. Thank you to everyone who worked on the forecast."),
                   ]),
            thread("q3-results", "Q3 review: internal summary", bucket: .updates, attachment: true,
                   oneLiner: "Q3 review: preview ring use was up 9% on the quarter, and voice sessions grew 21%.",
                   stands: "The quarterly summary for managers. Please keep it within the team.",
                   messages: [
                    (P.carlos, 200, "Attached is the internal summary of the Q3 review. Preview ring use grew 9% quarter over quarter and voice sessions grew 21%. Please keep this within the team."),
                   ]),
            thread("all-hands", "All-hands recap and recording", bucket: .updates,
                   oneLiner: "All-hands recap: the recording is posted and the Sandpiper demo starts at 24:10.",
                   stands: "A recap from Patti's office. The recording and slides are on the team site.",
                   messages: [
                    (P.debra, 122, "Thank you for joining yesterday's all-hands. The recording and slides are on the team site. The Sandpiper demo starts at 24:10."),
                   ]),
            thread("travel-policy", "Updated travel policy, effective \(C.md(10))", bucket: .updates, attachment: true,
                   oneLiner: "New travel policy from \(C.md(10)): book 14 days ahead, and hotel caps rise 8%.",
                   stands: "A policy update from Finance. The main changes are a 14-day booking rule and higher hotel caps.",
                   messages: [
                    (P.pradeep, 84, "The updated travel policy is attached and takes effect \(C.md(10)). Two changes: flights should be booked 14 days ahead where possible, and hotel caps go up 8% in major cities."),
                   ]),
            thread("holiday-schedule", "Holiday schedule and year-end shutdown", bucket: .updates,
                   oneLiner: "Offices close for the last week of December. Live site stays on rotation.",
                   stands: "HR's year-end schedule. Offices close for the final week of the year.",
                   messages: [
                    (P.diego, 180, "Offices will close for the last week of December. Live site and security operations remain on rotation. Please submit time off for adjacent days by the 1st."),
                   ]),
            thread("welcome-mona", "Please welcome Mona Kane", bucket: .updates,
                   oneLiner: "Mona Kane joined Design as a UX researcher.",
                   stands: "A welcome note. Mona is already running the frontline interviews for your team.",
                   messages: [
                    (P.grady, 260, "Please welcome Mona Kane, who joins Design as a UX researcher. Mona spent six years studying frontline workflows and will start with the Sandpiper frontline interviews."),
                   ]),
            thread("vpn-maintenance", "Planned maintenance: VPN on \(C.wd(3)) night", bucket: .updates,
                   oneLiner: "VPN will be down \(C.wd(3)) from 10 PM to midnight Pacific.",
                   stands: "An IT notice. Remote access is unavailable for two hours.",
                   messages: [
                    (P.allan, 17, "We're upgrading the VPN gateways on \(C.wd(3)) from 10 PM to midnight Pacific. Remote access to internal sites will be unavailable during that window. Microsoft 365 is not affected."),
                   ]),
            thread("ooo-lynne", "Out of office next week", bucket: .updates,
                   oneLiner: "Lynne is out next week. Irvin covers release planning.",
                   stands: "A coverage note. Irvin Sayers handles planning questions while Lynne is away.",
                   messages: [
                    (P.lynne, 33, "I'm out all of next week. Irvin has the release plan and can answer anything on dates. The floor move plan is in the team site."),
                   ]),
            thread("floor-move", "Floor 4 move: Outlook Mobile team to the east wing", bucket: .updates, attachment: true,
                   oneLiner: "Your team moves to the east wing of Floor 4 on \(C.md(11)). Crates arrive two days before.",
                   stands: "Facilities planning. Seating chart attached. No action until crates arrive.",
                   messages: [
                    (P.lynne, 88, "The Outlook Mobile team moves to the east wing of Floor 4 on \(C.md(11)). The seating chart is attached. Crates arrive two days before the move."),
                   ]),
            thread("sko-agenda", "Field kickoff: draft agenda", bucket: .updates, attachment: true,
                   oneLiner: "Draft field kickoff agenda: Sandpiper has the 45-minute opening slot on day two.",
                   stands: "Miriam's draft. You're pencilled in to present on day two. She hasn't asked for anything yet.",
                   messages: [
                    (P.miriam, 104, "Draft agenda for field kickoff is attached for comment. Vivek, I've given Sandpiper the opening slot on day two. I'll follow up separately on content."),
                   ]),
            thread("phishing-results", "Phishing simulation results", bucket: .updates,
                   oneLiner: "Phishing test: 6% of staff clicked. Your team had no clicks.",
                   stands: "Security's quarterly simulation results. The Product team had zero clicks.",
                   messages: [
                    (P.kevin, 135, "Results from last week's simulation: 6% of people clicked the link, down from 11%. Product, Legal and Finance had zero clicks. Thank you for reporting it."),
                   ]),
            thread("analyst-note", "FW: Analyst note on AI in mobile email", bucket: .updates, important: true, attachment: true,
                   oneLiner: "An analyst note names Outlook one of three mobile mail apps to watch for AI.",
                   stands: "Wanda forwarded a favorable analyst note. It can be quoted with attribution.",
                   messages: [
                    (P.wanda, 72, "Forwarding this morning's analyst note. We're named as one of three mobile mail apps to watch, and the voice catch-up pilot gets a paragraph. We can quote it with attribution."),
                   ]),
            thread("giving", "Giving campaign: we reached 112% of goal", bucket: .updates,
                   oneLiner: "The giving campaign closed at 112% of its goal.",
                   stands: "A thank-you from Patti. No action.",
                   messages: [
                    (P.patti, 210, "Thank you, everyone. This year's giving campaign closed at 112% of our goal, with 71% of the team taking part. The company match will be paid this month."),
                   ]),
        ]
    }
}
