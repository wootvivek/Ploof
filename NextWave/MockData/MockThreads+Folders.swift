import Foundation

private typealias P = MockPeople
private typealias C = MockClock

// MARK: - Archive, Sent, Drafts, Junk, Deleted

extension MockThreads {
    static var filed: [MailThread] { archived + sent + drafts + junk + deleted }

    private static var archived: [MailThread] {
        [
            thread("ar-expo", "Retail Expo: booth logistics", bucket: .updates, folder: .archive,
                   oneLiner: "Expo booth logistics, all wrapped up.",
                   stands: "Closed. The expo went ahead and the booth was returned.",
                   messages: [
                    (P.alexW, 420, "Booth 1410 is confirmed. Three demo units, two monitors, and badge pickup opens at 7 AM."),
                    (P.me, 418, "Thanks Alex. Lidia and I will run the demos."),
                   ]),
            thread("ar-fab-msa", "Fabrikam supply agreement: fully signed", bucket: .updates, folder: .archive, attachment: true,
                   oneLiner: "The Fabrikam supply agreement was signed by both sides.",
                   stands: "Closed. The signed agreement is in the contract repository.",
                   messages: [(P.joni, 600, "The Fabrikam supply agreement is fully signed. A copy is attached and filed in the contract repository.")]),
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
                   messages: [(P.elvia, 1600, "Notes from kickoff: 38 units across 6 sites, weekly check-ins on Thursdays, success measured on uptime and jobs per day.")]),
            thread("ar-beta", "Beta firmware 2.2 sign-off", bucket: .updates, folder: .archive,
                   oneLiner: "You signed off beta firmware 2.2 for the pilot sites.",
                   stands: "Closed. 2.2 shipped to pilots.",
                   messages: [
                    (P.colin, 900, "2.2 passed the 72-hour soak. Requesting sign-off to ship to pilot sites."),
                    (P.me, 898, "Signed off. Thanks to the whole firmware team."),
                   ]),
            thread("ar-trey-sow", "Trey Research SOW: pricing study", bucket: .updates, folder: .archive, attachment: true,
                   oneLiner: "The pricing study SOW with Trey Research, signed.",
                   stands: "Closed. Fieldwork is complete and the readout is being scheduled.",
                   messages: [(P.katri, 1100, "Countersigned SOW attached. Fieldwork begins Monday and runs four weeks.")]),
            thread("ar-press", "Press release draft v5: approved", bucket: .updates, folder: .archive,
                   oneLiner: "Launch press release v5 was approved by Legal and Comms.",
                   stands: "Closed. The release is locked until the embargo lifts.",
                   messages: [
                    (P.wanda, 240, "Legal has approved v5. Any last changes from you?"),
                    (P.me, 238, "None. It reads well. Lock it."),
                   ]),
            thread("ar-cab", "Customer advisory board recap", bucket: .updates, folder: .archive, attachment: true,
                   oneLiner: "Advisory board recap: offline mode and mounts were the top two asks.",
                   stands: "Closed. Both asks are on the H1 roadmap.",
                   messages: [(P.kat, 520, "Recap attached. Nine customers attended. The top two asks were offline mode and better mounting options.")]),
            thread("ar-mark7", "Mark 7 end-of-sale notice", bucket: .updates, folder: .archive,
                   oneLiner: "The Mark 7 end-of-sale notice went to customers.",
                   stands: "Closed. Support for the Mark 7 continues for three years.",
                   messages: [(P.megan, 700, "The Mark 7 end-of-sale notice went to all customers this morning. Support continues for three years.")]),
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
                   messages: [(P.irvin, 800, "Final Q3 business review deck attached. Thanks for the quick turnaround on the Mark 8 slides.")]),
        ]
    }

    private static var sent: [MailThread] {
        [
            thread("st-guardrails", "Mark 8 pricing guardrails for the field", bucket: .waiting, folder: .sent,
                   oneLiner: "You sent Sales the pricing guardrails: no discounts beyond 12% without approval.",
                   stands: "Sent to Miriam and the sales team. No reply needed.",
                   messages: [
                    (P.miriam, 174, "Can you put the discount rules in writing before quotes start going out?"),
                    (P.me, 172, "Hey Miriam, here they are. List price holds through launch. Volume discounts start at 1,000 units. Nothing beyond 12% without my approval. The dashboard stays bundled. Thanks!"),
                   ]),
            thread("st-charlotte-thanks", "Thank you for hosting us", bucket: .waiting, folder: .sent,
                   oneLiner: "Your thank-you note to Charlotte after the Northwind store tour.",
                   stands: "Sent. No reply expected.",
                   messages: [
                    (P.charlotte, 400, "Great to have you in Chicago. Let me know if the team needs anything else from the store tour."),
                    (P.me, 396, "Hey Charlotte, thank you for hosting us. Seeing store #118 during the morning rush taught us more than a month of interviews. Thanks!"),
                   ]),
            thread("st-intro", "Intro: Mona Kane and Katri Ahokas", bucket: .waiting, folder: .sent,
                   oneLiner: "You introduced Mona to Katri at Trey Research.",
                   stands: "Sent. They've taken it from there.",
                   messages: [
                    (P.mona, 300, "Could you introduce me to whoever ran the pricing study? I'd love to reuse their panel."),
                    (P.me, 298, "Hey Katri, meet Mona Kane, our UX researcher. Mona, Katri ran the pricing study. I'll let you two connect. Thanks!"),
                   ]),
            thread("st-henrietta", "Promotion case for Henrietta Mueller", bucket: .waiting, folder: .sent,
                   oneLiner: "You sent Colin your support for Henrietta's promotion.",
                   stands: "Sent. Colin will include it in the promotion packet.",
                   messages: [
                    (P.colin, 260, "I'm putting Henrietta up for Senior Developer. Would you write a few lines from the product side?"),
                    (P.me, 255, "Hey Colin, gladly. Henrietta rebuilt the update pipeline in six weeks and it has not failed once in the pilot. She explains trade-offs in a way my team can act on. Strong support from me. Thanks!"),
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
                    (P.me, 105, "Hey Megan, it's strong. Two notes: open with the technician quote, and cut the spec slide. Nobody remembers specs. Thanks!"),
                   ]),
        ]
    }

    private static var drafts: [MailThread] {
        [
            thread("dr-risk", "Mark 8 launch risk summary", bucket: .waiting, folder: .drafts,
                   oneLiner: "Draft: your one-page launch risk summary for Erik.",
                   stands: "An unsent draft. Erik asked for this before your 1:1.",
                   messages: [(P.me, 2.2, "Erik, here is the one-page view. Three risks: battery yield (mitigated by Rev C, costs four days), security findings (one high, fix merged), and Northwind contract timing (two open terms).")]),
            thread("dr-team", "Thank you, and what's next", bucket: .waiting, folder: .drafts,
                   oneLiner: "Draft: a note to the Mark 8 team ahead of the launch gate.",
                   stands: "An unsent draft.",
                   messages: [(P.me, 30, "Team, before the launch gate I want to say thank you. Eighteen months ago this was a sketch on a whiteboard.")]),
            thread("dr-ray", "Offline mode and the rugged case", bucket: .waiting, folder: .drafts,
                   oneLiner: "Draft: your answer to Ray on offline mode and a rugged case.",
                   stands: "An unsent draft. Ray is waiting on this answer.",
                   messages: [(P.me, 16, "Ray, on your two asks: offline mode is planned for the spring release, and for the rugged case I'd like to")]),
        ]
    }

    private static var junk: [MailThread] {
        [
            thread("jk-password", "URGENT: Your mailbox will be deactivated", bucket: .notifications, folder: .junk, unread: true,
                   oneLiner: "Phishing: a fake IT notice asking for your password.",
                   stands: "This is a phishing attempt. The sender isn't a Contoso address and the link goes to an unknown site. Don't click it.",
                   messages: [(P.phish1, 18, "Your mailbox has exceeded its quota and will be deactivated in 24 hours. Verify your password here to keep your account active.")]),
            thread("jk-gift", "You have been selected: $500 gift card", bucket: .notifications, folder: .junk, unread: true,
                   oneLiner: "Scam: a gift card 'reward' that asks for personal details.",
                   stands: "A scam message. Safe to delete.",
                   messages: [(P.phish2, 40, "Congratulations! You have been selected to receive a $500 gift card. Confirm your details within 48 hours to claim.")]),
            thread("jk-leads", "10,000 verified retail decision makers", bucket: .notifications, folder: .junk,
                   oneLiner: "Unsolicited offer to sell a contact list.",
                   stands: "Bulk sales mail. Safe to delete.",
                   messages: [(P.spam1, 65, "Hi Vivek, I'll keep this short. We have 10,000 verified retail decision makers ready for your Mark 8 launch. Worth a quick call?")]),
            thread("jk-expo", "Retail Expo attendee list available", bucket: .notifications, folder: .junk,
                   oneLiner: "Unsolicited offer to sell an expo attendee list.",
                   stands: "Bulk sales mail. The expo organizer doesn't sell attendee data.",
                   messages: [(P.spam2, 150, "We have the full attendee list for Retail Expo with emails and phone numbers. Reply for pricing.")]),
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
                   messages: [(P.gdi, 270, "Last chance to join 'Color systems for hardware'. We start in one hour.")]),
            thread("dl-parking", "Garage level P3 reopened", bucket: .notifications, folder: .deleted,
                   oneLiner: "Parking level P3 reopened last week.",
                   stands: "Deleted.",
                   messages: [(P.facilities, 190, "Level P3 of the Building 2 garage has reopened.")]),
        ]
    }
}
