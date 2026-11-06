import Foundation

/// A fake but believable mailbox for the UX prototype.
/// Times are relative to "now" so the demo always looks fresh.
enum MockThreads {
    private typealias P = MockPeople

    private static func ago(_ hours: Double) -> Date {
        Date.now.addingTimeInterval(-hours * 3600)
    }

    private static func thread(
        _ id: String,
        _ subject: String,
        bucket: TriageBucket,
        unread: Bool = false,
        flagged: Bool = false,
        attachment: Bool = false,
        oneLiner: String,
        stands: String,
        replies: [String] = [],
        messages: [(Person, Double, String)]
    ) -> MailThread {
        MailThread(
            id: id,
            subject: subject,
            bucket: bucket,
            isUnread: unread,
            isFlagged: flagged,
            hasAttachment: attachment,
            oneLiner: oneLiner,
            stands: stands,
            suggestedReplies: replies,
            messages: messages.enumerated().map { index, item in
                Message(id: "\(id)-\(index)", from: item.0, date: ago(item.1), body: item.2)
            }
        )
    }

    static var all: [MailThread] {
        [
            // MARK: Needs you
            thread("q4-deck", "Q4 planning deck", bucket: .needsYou, unread: true,
                   oneLiner: "Priya needs your Q4 deck (plus hiring numbers) before the review.",
                   stands: "You promised Priya the Q4 deck before the review, and it's due today. Her last note also asked for hiring numbers. Nothing has been sent yet.",
                   replies: ["Sending it over this afternoon!", "Will add the hiring numbers, thanks.", "Can I send a draft first?"],
                   messages: [
                    (P.priya, 26, "Hi Vivek, for next week's planning review I'd love to have your Q4 deck a day early so I can stitch it into the master. Can you get it to me before the review?"),
                    (P.me, 24, "Yes, I'll send the deck over before the review. Still polishing the roadmap slide."),
                    (P.priya, 2, "Perfect. If you can include the hiring numbers too, that'd be great. Thanks!"),
                   ]),
            thread("lease", "Lease renewal for Unit 4B", bucket: .needsYou, unread: true, attachment: true,
                   oneLiner: "Marcus sent the 4B renewal (rent +3%). Sign by the 10th.",
                   stands: "The renewal is waiting on your signature. Rent rises 3% in January, and Marcus needs it back by the 10th to hold the unit.",
                   replies: ["Signed and attached. Thanks Marcus!", "Could we talk about the increase?", "Got it, I'll sign this weekend."],
                   messages: [
                    (P.marcus, 30, "Hi Vivek, attached is the renewal for 4B. Rent goes up 3% starting January. Please sign and return by the 10th so I can hold the unit for you."),
                   ]),
            thread("dentist", "Please confirm your cleaning appointment", bucket: .needsYou, unread: true,
                   oneLiner: "Confirm Tuesday's 3 PM cleaning with Dr. Park.",
                   stands: "Lakeview Dental is waiting on a confirmation for Tuesday at 3 PM. One reply and it's done.",
                   replies: ["C", "Confirmed, see you Tuesday!", "Can we move it to Thursday?"],
                   messages: [
                    (P.dental, 5, "Hi Vivek, this is a reminder of your cleaning on Tuesday at 3:00 PM with Dr. Park. Reply C to confirm or call us to reschedule."),
                   ]),
            thread("hike", "Hike this weekend?", bucket: .needsYou,
                   oneLiner: "Sam's driving to a hike this weekend. Pick Sat or Sun.",
                   stands: "Sam is waiting on your pick: Saturday or Sunday, Rattlesnake Ledge or Mailbox Peak.",
                   replies: ["Saturday works! Rattlesnake?", "Sunday's better for me.", "Can't this weekend. Next one?"],
                   messages: [
                    (P.sam, 8, "Thinking Rattlesnake Ledge or Mailbox Peak this weekend. Sat or Sun work better? I can drive."),
                   ]),
            thread("thanksgiving", "Thanksgiving flights??", bucket: .needsYou, unread: true,
                   oneLiner: "Mom's still waiting on your Thanksgiving flight details.",
                   stands: "You promised Mom your flight details by yesterday, so it's now overdue. Dad needs your arrival time to plan the pickup.",
                   replies: ["Booking tonight, will send times!", "Landing Wed at 4:30 PM. Love you!", "Sorry Mom, today for sure."],
                   messages: [
                    (P.mom, 50, "Did you book your flights yet? Dad wants to know when to pick you up. Let me know by tomorrow!!"),
                    (P.me, 49, "Not yet. I'll confirm the flights by tomorrow, promise."),
                    (P.mom, 3, "Tomorrow was yesterday 😊 Any news?"),
                   ]),
            thread("kitchen", "Kitchen quote: $4,200", bucket: .needsYou, attachment: true,
                   oneLiner: "Approve Jordan's $4,200 kitchen quote to start in two weeks.",
                   stands: "The final quote is $4,200 for the backsplash and lighting. Approving soon keeps the start date.",
                   replies: ["Approved, let's do it!", "Can we drop the under-cabinet lights?", "Need a day to review."],
                   messages: [
                    (P.jordan, 20, "Attached is the final quote for the kitchen backsplash and lighting: $4,200 all in. If you approve by Friday we can start the week after next."),
                   ]),
            thread("intro", "Intro: Aisha ↔ Vivek", bucket: .needsYou,
                   oneLiner: "Aisha (design lead) wants coffee next week. Reply with times.",
                   stands: "Tom introduced you to Aisha. She's asked for coffee next week and is waiting on times from you.",
                   replies: ["Tue or Wed morning work?", "Would love to. How's Thursday?", "Sending you an invite now."],
                   messages: [
                    (P.tom, 28, "Aisha, meet Vivek. He's the person I mentioned who's building a new mail app. Vivek, Aisha runs design at a small studio and has strong opinions about inboxes. I'll let you two take it from here!"),
                    (P.aisha, 27, "Thanks Tom! Vivek, would love to grab coffee sometime next week. What works?"),
                   ]),

            // MARK: Waiting on others
            thread("concert", "Re: Concert tickets", bucket: .waiting,
                   oneLiner: "Alex still owes you $85 for the concert tickets.",
                   stands: "Alex promised to send $85 by Friday. That deadline passed and nothing has come through.",
                   replies: ["Hey! Friendly nudge on the $85 🙂", "No rush, whenever you can.", "Got it, thanks!"],
                   messages: [
                    (P.me, 120, "Got us two tickets for Saturday. $170 total."),
                    (P.alex, 118, "Legend. I'll Venmo you my $85 by Friday!"),
                   ]),
            thread("reference", "Reference letter", bucket: .waiting,
                   oneLiner: "Hannah promised a reference-letter draft, and it's late.",
                   stands: "Hannah said she'd send the draft. It's now a day overdue, and the program deadline is in two weeks.",
                   replies: ["Hi Hannah, any luck with the draft?", "No rush, the deadline's in two weeks.", "Thanks so much!"],
                   messages: [
                    (P.me, 100, "Thanks again for agreeing to write the reference for the Lakeside program!"),
                    (P.hannah, 98, "Of course! I'll send you a draft Monday so you can sanity-check it."),
                   ]),
            thread("refund", "Your refund request #48213", bucket: .waiting,
                   oneLiner: "Brightline owes you a $23.40 outage credit within 5 business days.",
                   stands: "The refund for the Oct 28 outage was approved. It should land next week, and Ploof will flag it if it doesn't.",
                   messages: [
                    (P.brightline, 72, "We're sorry about the outage on October 28. A credit of $23.40 will be applied to your account within 5 business days."),
                   ]),
            thread("photos", "Wedding photos!", bucket: .waiting,
                   oneLiner: "Tom will share the wedding album once he picks favorites.",
                   stands: "Tom has the photos and promised to share the album link. He didn't give a date.",
                   replies: ["Can't wait to see them!", "Please hide the dancing ones 😅"],
                   messages: [
                    (P.tom, 60, "The photographer sent everything over. I'll share the full album link once I pick the favorites. So many good ones of you dancing 😂"),
                   ]),
            thread("bookclub", "December book?", bucket: .waiting,
                   oneLiner: "Lena's confirming the December book pick with the group.",
                   stands: "You voted. Lena is checking with everyone and will confirm.",
                   messages: [
                    (P.me, 40, "I vote for Tomorrow, and Tomorrow, and Tomorrow."),
                    (P.lena, 39, "Great pick. Let me check with the others and I'll confirm by the weekend."),
                   ]),
            thread("car", "Your Civic", bucket: .waiting,
                   oneLiner: "Carlos will call when the brake pads arrive.",
                   stands: "Your car is waiting on parts. Carlos promised to call when they arrive so it can be done the same day.",
                   replies: ["Thanks Carlos!", "Can you also check the tire pressure light?"],
                   messages: [
                    (P.carlos, 26, "Brake pads are on order. I'll call you as soon as they arrive, should be Wednesday, and we can have it done same day."),
                   ]),

            // MARK: FYI
            thread("offsite", "Offsite moved to Dec 4", bucket: .fyi,
                   oneLiner: "The team offsite moved to Dec 4. Nothing else changed.",
                   stands: "Just a date change. No action needed.",
                   messages: [
                    (P.priya, 30, "Heads up: the team offsite moved to December 4 because of venue availability. Same agenda, same place."),
                   ]),
            thread("dinner", "Your reservation is confirmed", bucket: .fyi,
                   oneLiner: "Dinner for 2 at Trattoria Sole, Saturday at 7:30 PM.",
                   stands: "You're booked. Nothing to do.",
                   messages: [
                    (P.trattoria, 10, "Table for 2 on Saturday at 7:30 PM. We look forward to seeing you!"),
                   ]),
            thread("soccer", "Winter soccer schedule", bucket: .fyi, attachment: true,
                   oneLiner: "Winter soccer: Tuesdays 5–6 PM, first game Dec 6.",
                   stands: "Schedule only. Practices are Tuesdays at Greenlake field.",
                   messages: [
                    (P.coach, 34, "Attached is the winter schedule. Practices are Tuesdays 5–6 PM at Greenlake field. First game is December 6."),
                   ]),
            thread("blockparty", "Holiday block party 🎄", bucket: .fyi,
                   oneLiner: "Block party Dec 13, 4–7 PM. Bring a dish if you can.",
                   stands: "An invite with no RSVP needed.",
                   messages: [
                    (P.neighbors, 48, "Our holiday block party is Dec 13 from 4–7 PM at the Andersons'. Bring a dish if you can!"),
                   ]),
            thread("grandma", "Grandma's birthday card", bucket: .fyi,
                   oneLiner: "Maya's covering Grandma's card. You'll split the flowers later.",
                   stands: "Maya is handling the card. You owe her half for the flowers at some point.",
                   replies: ["You're the best. Sending my half now!", "Thanks Maya ❤️"],
                   messages: [
                    (P.maya, 15, "I got Grandma a card and I'll sign both our names, so you're covered! You can Venmo me for half of the flowers later."),
                   ]),
            thread("trip", "Trip photos 📸", bucket: .fyi,
                   oneLiner: "Sam uploaded the coast-trip photos to the shared album.",
                   stands: "Photos are up. Nothing to do.",
                   messages: [
                    (P.sam, 70, "Uploaded everything from the coast trip to the shared album. The sunset ones came out amazing."),
                   ]),

            // MARK: Updates
            thread("flight", "Your trip to Boston: confirmation K7XQ2P", bucket: .updates, attachment: true,
                   oneLiner: "SEA → BOS on Dec 21 at 7:05 AM, seat 14A.",
                   stands: "Your flight is booked and nothing needs attention. Ploof will remind you the day before.",
                   messages: [
                    (P.northwind, 200, "Thanks for flying Northwind. Flight NW 482, Seattle (SEA) → Boston (BOS), Monday, Dec 21. Departs 7:05 AM, arrives 3:32 PM. Seat 14A. Confirmation: K7XQ2P."),
                   ]),
            thread("coffee", "Your receipt from Bean & Leaf", bucket: .updates,
                   oneLiner: "Receipt: oat latte, $6.25.",
                   stands: "A receipt. Filed.",
                   messages: [(P.bean, 6, "Oat latte (large): $6.25. Thanks for stopping by!")]),
            thread("digest", "Today: chips, rockets & a very tired robot", bucket: .updates,
                   oneLiner: "Daily tech digest: 5 stories, a 4-minute read.",
                   stands: "A newsletter. Filed.",
                   messages: [(P.morningByte, 9, "Your daily tech digest: 5 stories, 4-minute read.")]),
            thread("bank", "Your November statement is ready", bucket: .updates,
                   oneLiner: "November statement is ready (account ••4417).",
                   stands: "A statement notice. Nothing due.",
                   messages: [(P.harbor, 40, "Your statement for account ending 4417 is ready to view in online banking.")]),
            thread("parcel", "Delivered: your package", bucket: .updates,
                   oneLiner: "Package delivered to the front porch yesterday afternoon.",
                   stands: "Delivered. Nothing to do.",
                   messages: [(P.parcel, 22, "Your package was delivered to the front porch at 2:14 PM.")]),
            thread("security", "New sign-in on iPhone", bucket: .updates,
                   oneLiner: "New sign-in from your iPhone in Seattle. Looks like you.",
                   stands: "Ploof matched this to your own iPhone. No action needed.",
                   messages: [(P.security, 12, "We noticed a new sign-in to your account from iPhone in Seattle, WA. If this was you, no action is needed.")]),
            thread("stride", "Your week in motion", bucket: .updates,
                   oneLiner: "14.2 miles this week, up 3 from last week.",
                   stands: "A weekly recap. Filed.",
                   messages: [(P.stride, 30, "You ran 14.2 miles this week, 3 more than last week. Keep it up!")]),
            thread("bill", "Your bill is ready", bucket: .updates,
                   oneLiner: "November internet bill: $64.99, autopay on.",
                   stands: "Autopay is on, so nothing to do.",
                   messages: [(P.brightline, 80, "Your November bill of $64.99 is ready. Autopay is on, so you're all set.")]),
        ]
    }
}
