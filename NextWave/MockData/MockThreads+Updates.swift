import Foundation

private typealias P = MockPeople
private typealias C = MockClock

// MARK: - Updates (written by people, no action needed)

extension MockThreads {
    /// Launch and customer news that needs no action.
    static var updatesLaunch: [MailThread] {
        [
            thread("launch-gate", "Mark 8 launch gate moved to \(C.md(9))", bucket: .updates, important: true, unread: true,
                   oneLiner: "The launch gate review moved to \(C.md(9)) so the certification report can be included.",
                   stands: "A date change only. The gate moved two days so the final certification report is in hand.",
                   messages: [
                    (P.irvin, 6, "Team, the launch gate review moves to \(C.md(9)) so we have the final certification report in hand. Same room, same attendees. Updated invite to follow."),
                   ]),
            thread("weekly-status", "Mark 8 weekly status report", bucket: .updates, important: true, attachment: true,
                   oneLiner: "Status: 2 green, 2 yellow (battery yield, security findings), 0 red.",
                   stands: "The weekly report. Battery yield and the security findings are yellow, both already with you. Nothing new to act on.",
                   messages: [
                    (P.irvin, 28, "Weekly status is attached. Summary: firmware and packaging are green. Battery yield and the security findings are yellow. No reds. Pre-orders stand at 6,140 against a plan of 5,500."),
                   ]),
            thread("firmware-232", "Firmware 2.3.2 release notes", bucket: .updates, important: true,
                   oneLiner: "Firmware 2.3.2 fixes the Wi-Fi roaming fault and goes to pilot sites \(C.wd(2)).",
                   stands: "Release notes for the fix to the store #412 fault. It goes to pilot sites on \(C.wd(2)) after a 48-hour soak.",
                   messages: [
                    (P.colin, 0.5, "2.3.2 is built. It reverts the roaming change and adds a test on legacy access points. It goes to pilot sites on \(C.wd(2)) after a 48-hour soak."),
                   ]),
            thread("win-alpine", "WIN: Alpine Ski House signs for 60 units", bucket: .updates, important: true,
                   oneLiner: "Alpine Ski House signed for 60 Mark 8 units across four resorts.",
                   stands: "A sales win announcement. It's the first hospitality customer for the Mark 8.",
                   messages: [
                    (P.isaiah, 32, "Happy to share that Alpine Ski House signed for 60 Mark 8 units across four resorts. It's our first hospitality customer. Thanks to Vivek's team for the demo support."),
                    (P.miriam, 31, "Great work, Isaiah. Hospitality wasn't on our list six months ago."),
                   ]),
            thread("customer-quote", "A customer quote you can use", bucket: .updates,
                   oneLiner: "An Adventure Works technician: 'I stopped carrying the clipboard in week two.'",
                   stands: "Elvia shared a quote from the pilot. It's approved for internal decks only.",
                   messages: [
                    (P.elvia, 49, "From one of the Adventure Works technicians, shared with permission for internal decks: 'I stopped carrying the clipboard in week two.' Thought you'd enjoy it."),
                   ]),
            thread("vanarsdel-v3", "VanArsdel announces V3 pricing", bucket: .updates, attachment: true,
                   oneLiner: "VanArsdel cut the V3 to $329, with the dashboard sold separately at $8 a month.",
                   stands: "Competitive news. Babak's analysis shows the V3 costs more than the Mark 8 over three years once the dashboard fee is added.",
                   messages: [
                    (P.babak, 98, "VanArsdel announced the V3 at $329, down from $379. The dashboard is a separate $8 per unit per month. Over three years that's $617 a unit against our bundled price. My analysis is attached."),
                   ]),
            thread("fab-po", "RE: Fabrikam PO 88214 delivery schedule", bucket: .updates,
                   oneLiner: "Christie and Mauricio agreed three deliveries for PO 88214. You're on copy.",
                   stands: "A procurement thread you're copied on. Deliveries are set for three dates and will shift four days if Rev C is approved.",
                   messages: [
                    (P.christie, 41, "Mauricio, confirming PO 88214 for 12,000 battery modules in three deliveries of 4,000."),
                    (P.mauricio, 39, "Confirmed. If Rev C is approved, each delivery moves out four days. Copying Vivek for awareness."),
                   ]),
            thread("store-visits", "Store visit notes: Northwind #118 and #204", bucket: .updates, attachment: true,
                   oneLiner: "Adele's store visits: staff like the Mark 8, and the charging dock placement is awkward.",
                   stands: "Field notes from two Northwind stores. The main finding is that the charging dock sits too far from the service desk.",
                   messages: [
                    (P.adele, 53, "Notes from two Northwind stores are attached. Staff picked it up in a day. The one consistent complaint is the charging dock, which sits too far from the service desk in both layouts."),
                   ]),
            thread("supply-connectors", "Supply update: connector lead time down to 6 weeks", bucket: .updates,
                   oneLiner: "Connector lead time dropped from 11 weeks to 6.",
                   stands: "Good supply news. The connector that held up the last build is no longer a risk for Q1.",
                   messages: [
                    (P.cecil, 67, "Good news from the connector supplier: lead time is down from 11 weeks to 6. That removes it from the Q1 risk list."),
                   ]),
            thread("support-trends", "Support ticket trends: last month", bucket: .updates, attachment: true,
                   oneLiner: "Pilot support tickets fell 22%. Pairing problems are still the top issue.",
                   stands: "Robin's monthly support summary. Volume is down, and Bluetooth pairing remains the most common ticket.",
                   messages: [
                    (P.robin, 110, "Monthly summary attached. Pilot tickets are down 22% month over month. Bluetooth pairing is still the top category at 31% of volume."),
                   ]),
            thread("comms-calendar", "Launch comms calendar v2", bucket: .updates, attachment: true,
                   oneLiner: "Updated launch comms calendar: the embargo lifts at 6 AM Pacific on launch day.",
                   stands: "The latest calendar from Marketing. Nothing changed on your items.",
                   messages: [
                    (P.alexW, 56, "Version 2 of the launch comms calendar is attached. The only change is the embargo time, which is now 6 AM Pacific on launch day."),
                   ]),
            thread("patent", "Patent filed: adaptive mount (ref CT-2291)", bucket: .updates,
                   oneLiner: "The adaptive mount patent application was filed. You're listed as a co-inventor.",
                   stands: "Legal filed the application. No action until the examiner responds, usually in 12 to 18 months.",
                   messages: [
                    (P.enrico, 140, "The adaptive mount application (our reference CT-2291) was filed yesterday. Vivek, Johanna and Grady are named as inventors. Nothing further is needed until the examiner responds, typically 12 to 18 months."),
                   ]),
            thread("design-crit", "Notes from design crit", bucket: .updates,
                   oneLiner: "Design crit notes: the status light is too dim in daylight.",
                   stands: "Grady's notes from the design review. The team will test a brighter status LED next sprint.",
                   messages: [
                    (P.grady, 78, "Notes from crit: the setup flow tested well. The status light is too dim in daylight. We'll try a brighter LED next sprint and report back."),
                   ]),
            thread("kayo-thanks", "Thank you for the roadmap session", bucket: .updates,
                   oneLiner: "Kayo says the Tokyo distributors appreciated your roadmap walkthrough.",
                   stands: "A thank-you note. No action.",
                   messages: [
                    (P.kayo, 115, "Vivek-san, thank you for joining so late in your evening. Both distributors said it was the clearest roadmap session they've had from us."),
                   ]),
        ]
    }

    /// Company news, policy and announcements.
    static var updatesCompany: [MailThread] {
        [
            thread("org-update", "Organization update: Operations and Supply Chain", bucket: .updates, important: true, unread: true,
                   oneLiner: "Supply Chain now reports to Nestor Wilke. Nothing changes for the Mark 8 team.",
                   stands: "An announcement from Patti. Cecil Folk's team moves under Nestor. Your team and reporting line are unchanged.",
                   messages: [
                    (P.patti, 14, "Team, effective the first of next month, Supply Chain will report to Nestor Wilke as part of Operations. Cecil Folk continues to lead the team. This puts planning, logistics and supply under one leader ahead of the Mark 8 ramp."),
                   ]),
            thread("board-inventory", "Board approved the Q1 inventory build", bucket: .updates,
                   oneLiner: "The board approved building 20,000 units ahead of Q1 demand.",
                   stands: "Finance confirmed the approval. It covers the first two Fabrikam deliveries.",
                   messages: [
                    (P.carlos, 160, "The board approved the Q1 inventory build of 20,000 units by written consent. Thank you to everyone who worked on the forecast."),
                   ]),
            thread("q3-results", "Q3 results: internal summary", bucket: .updates, attachment: true,
                   oneLiner: "Q3 revenue was up 9% year over year. Services grew 21%.",
                   stands: "The quarterly summary for managers. Confidential until earnings are published.",
                   messages: [
                    (P.carlos, 200, "Attached is the internal summary of Q3. Revenue grew 9% year over year and services grew 21%. Please keep this confidential until we publish."),
                   ]),
            thread("all-hands", "All-hands recap and recording", bucket: .updates,
                   oneLiner: "All-hands recap: the recording is posted and the Mark 8 demo starts at 24:10.",
                   stands: "A recap from the President's office. The recording and slides are on the intranet.",
                   messages: [
                    (P.debra, 122, "Thank you for joining yesterday's all-hands. The recording and slides are on Contoso Life. The Mark 8 demo starts at 24:10."),
                   ]),
            thread("travel-policy", "Updated travel policy, effective \(C.md(10))", bucket: .updates, attachment: true,
                   oneLiner: "New travel policy from \(C.md(10)): book 14 days ahead, and hotel caps rise 8%.",
                   stands: "A policy update from Finance. The main changes are a 14-day booking rule and higher hotel caps.",
                   messages: [
                    (P.pradeep, 84, "The updated travel policy is attached and takes effect \(C.md(10)). Two changes: flights should be booked 14 days ahead where possible, and hotel caps go up 8% in major cities."),
                   ]),
            thread("holiday-schedule", "Holiday schedule and year-end shutdown", bucket: .updates,
                   oneLiner: "Offices close for the last week of December. Support stays on rotation.",
                   stands: "HR's year-end schedule. Offices close for the final week of the year.",
                   messages: [
                    (P.diego, 180, "Contoso offices will close for the last week of December. Customer support and security operations remain on rotation. Please submit time off for adjacent days by the 1st."),
                   ]),
            thread("welcome-mona", "Please welcome Mona Kane", bucket: .updates,
                   oneLiner: "Mona Kane joined Design as a UX researcher.",
                   stands: "A welcome note. Mona is already running the store manager interviews for your team.",
                   messages: [
                    (P.grady, 260, "Please welcome Mona Kane, who joins Design as a UX researcher. Mona spent six years studying retail workflows and will start with the Mark 8 store manager interviews."),
                   ]),
            thread("vpn-maintenance", "Planned maintenance: VPN on \(C.wd(3)) night", bucket: .updates,
                   oneLiner: "VPN will be down \(C.wd(3)) from 10 PM to midnight Pacific.",
                   stands: "An IT notice. Remote access is unavailable for two hours.",
                   messages: [
                    (P.allan, 17, "We're upgrading the VPN gateways on \(C.wd(3)) from 10 PM to midnight Pacific. Remote access to internal sites will be unavailable during that window. Microsoft 365 is not affected."),
                   ]),
            thread("ooo-lynne", "Out of office next week", bucket: .updates,
                   oneLiner: "Lynne is out next week. Irvin covers launch planning.",
                   stands: "A coverage note. Irvin Sayers handles planning questions while Lynne is away.",
                   messages: [
                    (P.lynne, 33, "I'm out all of next week. Irvin has the launch plan and can answer anything on dates. The floor move plan is in the team site."),
                   ]),
            thread("floor-move", "Floor 4 move: Mark 8 team to the east wing", bucket: .updates, attachment: true,
                   oneLiner: "Your team moves to the east wing of Floor 4 on \(C.md(11)). Crates arrive two days before.",
                   stands: "Facilities planning. Seating chart attached. No action until crates arrive.",
                   messages: [
                    (P.lynne, 88, "The Mark 8 team moves to the east wing of Floor 4 on \(C.md(11)). The seating chart is attached. Crates arrive two days before the move."),
                   ]),
            thread("sko-agenda", "Sales kickoff: draft agenda", bucket: .updates, attachment: true,
                   oneLiner: "Draft sales kickoff agenda: the Mark 8 has the 45-minute opening slot on day two.",
                   stands: "Miriam's draft. You're pencilled in to present on day two. She hasn't asked for anything yet.",
                   messages: [
                    (P.miriam, 104, "Draft agenda for sales kickoff is attached for comment. Vivek, I've given the Mark 8 the opening slot on day two. I'll follow up separately on content."),
                   ]),
            thread("phishing-results", "Phishing simulation results", bucket: .updates,
                   oneLiner: "Phishing test: 6% of staff clicked. Your team had no clicks.",
                   stands: "Security's quarterly simulation results. The Product team had zero clicks.",
                   messages: [
                    (P.kevin, 135, "Results from last week's simulation: 6% of employees clicked the link, down from 11%. Product, Legal and Finance had zero clicks. Thank you for reporting it."),
                   ]),
            thread("analyst-note", "FW: Analyst note on connected retail devices", bucket: .updates, important: true, attachment: true,
                   oneLiner: "An analyst note names Contoso one of three vendors to watch in connected retail.",
                   stands: "Wanda forwarded a favorable analyst note. It can be quoted with attribution.",
                   messages: [
                    (P.wanda, 72, "Forwarding this morning's analyst note. We're named as one of three vendors to watch, and the Mark 8 pilot gets a paragraph. We can quote it with attribution."),
                   ]),
            thread("giving", "Giving campaign: we reached 112% of goal", bucket: .updates,
                   oneLiner: "The giving campaign closed at 112% of its goal.",
                   stands: "A thank-you from Patti. No action.",
                   messages: [
                    (P.patti, 210, "Thank you, everyone. This year's giving campaign closed at 112% of our goal, with 71% of employees taking part. The company match will be paid this month."),
                   ]),
        ]
    }
}
