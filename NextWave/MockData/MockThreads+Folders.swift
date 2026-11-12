import Foundation

private typealias P = MockPeople
private typealias C = MockClock

// MARK: - Archive, Sent, Drafts, Junk, Deleted

extension MockThreads {
    static var filed: [MailThread] { archived + sent + drafts + junk + deleted }

    private static var archived: [MailThread] {
        [
            thread("ar-expo", "Partner summit: booth logistics", bucket: .updates, folder: .archive,
                   oneLiner: "Partner summit booth logistics, all wrapped up.",
                   stands: "Closed. The summit went ahead and the booth was returned.",
                   messages: [
                    (P.alexW, 420, "Booth 1410 is confirmed. Three demo phones, two monitors, and badge pickup opens at 7 AM."),
                    (P.me, 418, "Thanks Alex. Lidia and I will run the demos."),
                   ]),
            thread("ar-fab-msa", "Fabrikam Test Labs agreement: fully signed", bucket: .updates, folder: .archive, attachment: true,
                   oneLiner: "The Fabrikam Test Labs agreement was signed by both sides.",
                   stands: "Closed. The signed agreement is in the contract repository.",
                   messages: [(P.joni, 600, "The Fabrikam Test Labs agreement is fully signed. A copy is attached and filed in the contract repository.")]),
            thread("ar-cameron-loop", "Interview loop feedback: Cameron Evans", bucket: .updates, folder: .archive,
                   oneLiner: "Panel feedback for Cameron Evans: five strong hires.",
                   stands: "Closed. The offer approval is now with you in Needs you.",
                   messages: [
                    (P.amanda, 80, "All five interviewers submitted feedback: five 'strong hire'. Summary is in the hiring tool."),
                    (P.me, 79, "Great. Let's move to offer."),
                   ]),
            thread("ar-pilot-kickoff", "Adventure Works pilot kickoff notes", bucket: .updates, folder: .archive,
                   oneLiner: "Kickoff notes from the start of the Adventure Works pilot.",
                   stands: "Closed. The pilot has finished.",
                   messages: [(P.elvia, 1600, "Notes from kickoff: 380 field staff across 6 sites, weekly check-ins on Thursdays, success measured on crash-free sessions and mail cleared before the first job.")]),
            thread("ar-beta", "Beta build 4.2440 sign-off", bucket: .updates, folder: .archive,
                   oneLiner: "You signed off beta build 4.2440 for the pilot sites.",
                   stands: "Closed. 4.2440 shipped to pilots.",
                   messages: [
                    (P.colin, 900, "4.2440 passed the 72-hour soak. Requesting sign-off to ship to pilot sites."),
                    (P.me, 898, "Signed off. Thanks to the whole client team."),
                   ]),
            thread("ar-trey-sow", "Trey Research SOW: user study", bucket: .updates, folder: .archive, attachment: true,
                   oneLiner: "The user study SOW with Trey Research, signed.",
                   stands: "Closed. Fieldwork is complete and the readout is being scheduled.",
                   messages: [(P.katri, 1100, "Countersigned SOW attached. Fieldwork begins Monday and runs four weeks.")]),
            thread("ar-press", "Sandpiper blog post draft v5: approved", bucket: .updates, folder: .archive,
                   oneLiner: "The Sandpiper blog post v5 was approved by Legal and Comms.",
                   stands: "Closed. The post is locked until the embargo lifts.",
                   messages: [
                    (P.wanda, 240, "Legal has approved v5. Any last changes from you?"),
                    (P.me, 238, "None. It reads well. Lock it."),
                   ]),
            thread("ar-cab", "Customer advisory board recap", bucket: .updates, folder: .archive, attachment: true,
                   oneLiner: "Advisory board recap: offline playback and shared device sign-in were the top two asks.",
                   stands: "Closed. Both asks are on the H1 roadmap.",
                   messages: [(P.kat, 520, "Recap attached. Nine customers attended. The top two asks were offline voice playback and faster sign-in on shared devices.")]),
            thread("ar-mark7", "Outlook Lite retirement notice", bucket: .updates, folder: .archive,
                   oneLiner: "The retirement notice for the lightweight Android app went to customers.",
                   stands: "Closed. Users are being moved to the main app.",
                   messages: [(P.megan, 700, "The retirement notice for the lightweight Android app went to all customers this morning. In-app prompts will move people to the main app.")]),
            thread("ar-lunch", "Team lunch on Friday", bucket: .updates, folder: .archive,
                   oneLiner: "Team lunch plans from last month.",
                   stands: "Closed.",
                   messages: [
                    (P.lidia, 480, "Team lunch Friday? I can book the place on 152nd."),
                    (P.me, 479, "Yes please. Table for eight."),
                   ]),
            thread("ar-venues", "Offsite venue shortlist", bucket: .updates, folder: .archive,
                   oneLiner: "The offsite venue shortlist. Alpine Ski House was chosen.",
                   stands: "Closed. The offsite is booked.",
                   messages: [(P.debra, 380, "Three venues made the shortlist. Patti chose Alpine Ski House.")]),
            thread("ar-q3-qbr", "Q3 business review: final deck", bucket: .updates, folder: .archive, attachment: true,
                   oneLiner: "The final Q3 business review deck.",
                   stands: "Closed.",
                   messages: [(P.irvin, 800, "Final Q3 business review deck attached. Thanks for the quick turnaround on the Sandpiper slides.")]),
        ]
    }

    private static var sent: [MailThread] {
        [
            thread("st-guardrails", "Sandpiper messaging guardrails for the field", bucket: .waiting, folder: .sent,
                   oneLiner: "You sent the field the messaging guardrails: no dates beyond the preview ring without approval.",
                   stands: "Sent to Miriam and the field team. No reply needed.",
                   messages: [
                    (P.miriam, 174, "Can you put the messaging rules in writing before customer briefings start?"),
                    (P.me, 172, "Hey Miriam, here they are. Talk about what is in the preview ring today. No dates beyond the preview ring without my approval. Voice catch-up needs a Copilot license, and say so up front. Thanks!"),
                   ]),
            thread("st-charlotte-thanks", "Thank you for hosting us", bucket: .waiting, folder: .sent,
                   oneLiner: "Your thank-you note to Charlotte after the Northwind store tour.",
                   stands: "Sent. No reply expected.",
                   messages: [
                    (P.charlotte, 400, "Great to have you in Chicago. Let me know if the team needs anything else from the store tour."),
                    (P.me, 396, "Hey Charlotte, thank you for hosting us. Seeing store #118 at shift change taught us more than a month of interviews. Thanks!"),
                   ]),
            thread("st-intro", "Intro: Mona Kane and Katri Ahokas", bucket: .waiting, folder: .sent,
                   oneLiner: "You introduced Mona to Katri at Trey Research.",
                   stands: "Sent. They've taken it from there.",
                   messages: [
                    (P.mona, 300, "Could you introduce me to whoever ran the user study? I'd love to reuse their panel."),
                    (P.me, 298, "Hey Katri, meet Mona Kane, our UX researcher. Mona, Katri ran the user study. I'll let you two connect. Thanks!"),
                   ]),
            thread("st-henrietta", "Promotion case for Henrietta Mueller", bucket: .waiting, folder: .sent,
                   oneLiner: "You sent Colin your support for Henrietta's promotion.",
                   stands: "Sent. Colin will include it in the promotion packet.",
                   messages: [
                    (P.colin, 260, "I'm putting Henrietta up for Senior Developer. Would you write a few lines from the product side?"),
                    (P.me, 255, "Hey Colin, gladly. Henrietta rebuilt the calendar drag engine in six weeks and it has not crashed once in the pilot. She explains trade-offs in a way my team can act on. Strong support from me. Thanks!"),
                   ]),
            thread("st-pto", "Time off: \(C.md(18)) to \(C.md(19))", bucket: .waiting, folder: .sent,
                   oneLiner: "You told Erik you'll be out \(C.md(18)) to \(C.md(19)).",
                   stands: "Sent. Erik acknowledged it.",
                   messages: [
                    (P.me, 210, "Hey Erik, I'm planning to be out \(C.md(18)) to \(C.md(19)). Lidia will cover. Thanks!"),
                    (P.erik, 208, "Approved. Enjoy it."),
                    (P.me, 207, "Thanks!"),
                   ]),
            thread("st-keynote", "Feedback on the keynote draft", bucket: .waiting, folder: .sent,
                   oneLiner: "Your notes to Megan on the sales kickoff keynote.",
                   stands: "Sent. Megan is revising.",
                   messages: [
                    (P.megan, 108, "Draft keynote for kickoff is in the team site. Honest feedback welcome."),
                    (P.me, 105, "Hey Megan, it's strong. Two notes: open with the supervisor quote, and cut the feature grid. Nobody remembers a feature grid. Thanks!"),
                   ]),
        ]
    }

    private static var drafts: [MailThread] {
        [
            thread("dr-risk", "Sandpiper release risk summary", bucket: .waiting, folder: .drafts,
                   oneLiner: "Draft: your one-page release risk summary for Erik.",
                   stands: "An unsent draft. Erik asked for this before your 1:1.",
                   messages: [(P.me, 2.2, "Erik, here is the one-page view. Three risks: Android crash rate (mitigated by RC3, costs four days), security findings (one high, fix merged), and Northwind agreement timing (two open terms).")]),
            thread("dr-team", "Thank you, and what's next", bucket: .waiting, folder: .drafts,
                   oneLiner: "Draft: a note to the Sandpiper team ahead of the release review.",
                   stands: "An unsent draft.",
                   messages: [(P.me, 30, "Team, before the release review I want to say thank you. Eighteen months ago this was a sketch on a whiteboard.")]),
            thread("dr-ray", "Offline playback and dashboard support", bucket: .waiting, folder: .drafts,
                   oneLiner: "Draft: your answer to Ray on offline playback and dashboard support.",
                   stands: "An unsent draft. Ray is waiting on this answer.",
                   messages: [(P.me, 16, "Ray, on your two asks: offline playback is planned for the spring release, and for dashboard support I'd like to")]),
        ]
    }

    private static var junk: [MailThread] {
        [
            thread("jk-password", "URGENT: Your mailbox will be deactivated", bucket: .notifications, folder: .junk, unread: true,
                   oneLiner: "Phishing: a fake IT notice asking for your password.",
                   stands: "This is a phishing attempt. The sender isn't a company address and the link goes to an unknown site. Don't click it.",
                   messages: [(P.phish1, 18, "Your mailbox has exceeded its quota and will be deactivated in 24 hours. Verify your password here to keep your account active.")]),
            thread("jk-gift", "You have been selected: $500 gift card", bucket: .notifications, folder: .junk, unread: true,
                   oneLiner: "Scam: a gift card 'reward' that asks for personal details.",
                   stands: "A scam message. Safe to delete.",
                   messages: [(P.phish2, 40, "Congratulations! You have been selected to receive a $500 gift card. Confirm your details within 48 hours to claim.")]),
            thread("jk-leads", "10,000 verified IT decision makers", bucket: .notifications, folder: .junk,
                   oneLiner: "Unsolicited offer to sell a contact list.",
                   stands: "Bulk sales mail. Safe to delete.",
                   messages: [(P.spam1, 65, "Hi Vivek, I'll keep this short. We have 10,000 verified IT decision makers ready for your next launch. Worth a quick call?")]),
            thread("jk-expo", "Partner summit attendee list available", bucket: .notifications, folder: .junk,
                   oneLiner: "Unsolicited offer to sell a summit attendee list.",
                   stands: "Bulk sales mail. The organizer doesn't sell attendee data.",
                   messages: [(P.spam2, 150, "We have the full attendee list for the partner summit with emails and phone numbers. Reply for pricing.")]),
        ]
    }

    private static var deleted: [MailThread] {
        [
            thread("dl-lunch", "Lunch and learn: spreadsheet tips", bucket: .notifications, folder: .deleted,
                   oneLiner: "An optional lunch-and-learn you skipped.",
                   stands: "Deleted.",
                   messages: [(P.learning, 250, "Join us Thursday at noon for 30 minutes of spreadsheet tips. Lunch provided.")]),
            thread("dl-webinar", "Last chance: webinar starts in 1 hour", bucket: .notifications, folder: .deleted,
                   oneLiner: "A reminder for a webinar that has passed.",
                   stands: "Deleted.",
                   messages: [(P.gdi, 270, "Last chance to join 'Color systems for dark mode'. We start in one hour.")]),
            thread("dl-parking", "Garage level P3 reopened", bucket: .notifications, folder: .deleted,
                   oneLiner: "Parking level P3 reopened last week.",
                   stands: "Deleted.",
                   messages: [(P.facilities, 190, "Level P3 of the Building 2 garage has reopened.")]),
        ]
    }
}
