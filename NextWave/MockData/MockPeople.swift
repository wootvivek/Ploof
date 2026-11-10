import Foundation

/// Synthetic people for the proof of concept. Edit freely.
///
/// The mailbox belongs to Vivek, Director of Product for the Mark 8 at Contoso.
/// Companies and most names are the fictitious ones Microsoft publishes for demos and docs
/// (Contoso, Fabrikam, Northwind Traders, the Microsoft 365 sample users, …). No real people or data.
enum MockPeople {
    private static func contoso(_ id: String, _ name: String, _ alias: String, _ hue: Double) -> Person {
        Person(id: id, name: name, email: "\(alias)@contoso.com", hue: hue)
    }

    private static func ext(_ id: String, _ name: String, _ email: String, _ hue: Double) -> Person {
        Person(id: id, name: name, email: email, hue: hue)
    }

    static let me = Person(id: "me", name: "Vivek", email: "vivek@contoso.com", hue: 0.68)

    // MARK: Contoso leadership
    static let patti = contoso("patti", "Patti Fernandez", "pattif", 0.95)        // President
    static let erik = contoso("erik", "Erik Nason", "erikn", 0.58)                // Chief Product Officer, Vivek's manager
    static let carlos = contoso("carlos", "Carlos Slattery", "carloss", 0.10)     // CFO
    static let miriam = contoso("miriam", "Miriam Graham", "miriamg", 0.83)       // Director, Sales & Marketing
    static let nestor = contoso("nestor", "Nestor Wilke", "nestorw", 0.30)        // Director, Operations
    static let lee = contoso("lee", "Lee Gu", "leeg", 0.47)                       // Director, Manufacturing

    // MARK: Contoso colleagues
    static let megan = contoso("megan", "Megan Bowen", "meganb", 0.90)            // Marketing Manager
    static let alexW = contoso("alexw", "Alex Wilber", "alexw", 0.40)             // Marketing Assistant
    static let adele = contoso("adele", "Adele Vance", "adelev", 0.02)            // Retail Manager
    static let allan = contoso("allan", "Allan Deyoung", "alland", 0.55)          // IT Admin
    static let christie = contoso("christie", "Christie Cline", "christiec", 0.78) // Buyer, Procurement
    static let debra = contoso("debra", "Debra Berger", "debrab", 0.13)           // Executive Assistant to Patti
    static let diego = contoso("diego", "Diego Siciliani", "diegos", 0.07)        // HR Manager
    static let emily = contoso("emily", "Emily Braun", "emilyb", 0.73)            // Budget Analyst
    static let enrico = contoso("enrico", "Enrico Cattaneo", "enricoc", 0.62)     // Attorney
    static let grady = contoso("grady", "Grady Archie", "gradya", 0.35)           // Designer
    static let henrietta = contoso("henrietta", "Henrietta Mueller", "henriettam", 0.87) // Developer
    static let irvin = contoso("irvin", "Irvin Sayers", "irvins", 0.52)           // Project Manager
    static let isaiah = contoso("isaiah", "Isaiah Langer", "isaiahl", 0.16)       // Sales Rep
    static let johanna = contoso("johanna", "Johanna Lorenz", "johannal", 0.98)   // Senior Engineer
    static let joni = contoso("joni", "Joni Sherman", "jonis", 0.80)              // Paralegal
    static let lidia = contoso("lidia", "Lidia Holloway", "lidiah", 0.93)         // Product Manager on Vivek's team
    static let lynne = contoso("lynne", "Lynne Robbins", "lynner", 0.22)          // Planner
    static let pradeep = contoso("pradeep", "Pradeep Gupta", "pradeepg", 0.44)    // Accountant
    static let kat = contoso("kat", "Kat Larsson", "katl", 0.75)                  // Product Manager on Vivek's team
    static let daisy = contoso("daisy", "Daisy Phillips", "daisyp", 0.05)         // Data Analyst
    static let elvia = contoso("elvia", "Elvia Atkins", "elviaa", 0.27)           // Customer Success
    static let kevin = contoso("kevin", "Kevin Sturgis", "kevins", 0.60)          // Security & Compliance
    static let mona = contoso("mona", "Mona Kane", "monak", 0.85)                 // UX Research
    static let colin = contoso("colin", "Colin Ballinger", "colinb", 0.50)        // Engineering Manager, Firmware
    static let robin = contoso("robin", "Robin Counts", "robinc", 0.00)           // Support Lead
    static let amanda = contoso("amanda", "Amanda Brady", "amandab", 0.88)        // Recruiter
    static let cecil = contoso("cecil", "Cecil Folk", "cecilf", 0.33)             // Supply Chain
    static let wanda = contoso("wanda", "Wanda Howard", "wandah", 0.70)           // Communications
    static let tim = contoso("tim", "Tim Deboer", "timd", 0.18)                   // QA Lead
    static let babak = contoso("babak", "Babak Shammas", "babaks", 0.42)          // Data Science
    static let kayo = contoso("kayo", "Kayo Miwa", "kayom", 0.97)                 // Country Manager, Japan

    // MARK: Customers and prospects
    static let charlotte = ext("charlotte", "Charlotte Waltson", "charlotte.waltson@northwindtraders.com", 0.57) // VP Store Operations
    static let aadi = ext("aadi", "Aadi Kapoor", "aadi.kapoor@northwindtraders.com", 0.12)                       // Procurement
    static let hillary = ext("hillary", "Hillary Reyes", "hillary.reyes@northwindtraders.com", 0.82)             // IT Security
    static let ray = ext("ray", "Ray Tanaka", "ray.tanaka@adventure-works.com", 0.37)                            // Head of Field Operations
    static let kristin = ext("kristin", "Kristin Patterson", "kristin.patterson@adventure-works.com", 0.91)      // Program Manager
    static let will = ext("will", "Will Little", "will.little@tailspintoys.com", 0.24)                           // Merchandising Director
    static let krystal = ext("krystal", "Krystal McKinney", "krystal.mckinney@wingtiptoys.com", 0.77)            // Store Technology

    // MARK: Suppliers, partners and advisers
    static let mauricio = ext("mauricio", "Mauricio August", "mauricio.august@fabrikam.com", 0.08)   // Account Director
    static let lydia = ext("lydia", "Lydia Bauer", "lydia.bauer@fabrikam.com", 0.65)                 // Quality Engineer
    static let robert = ext("robert", "Robert Tolbert", "robert.tolbert@woodgrovebank.com", 0.53)    // Relationship Manager
    static let celeste = ext("celeste", "Celeste Burton", "celeste.burton@litwareinc.com", 0.86)     // Account Executive
    static let serena = ext("serena", "Serena Davis", "serena.davis@proseware.com", 0.94)            // Creative Director
    static let miguel = ext("miguel", "Miguel Garcia", "miguel.garcia@proseware.com", 0.15)          // Account Lead
    static let katri = ext("katri", "Katri Ahokas", "katri.ahokas@treyresearch.net", 0.72)           // Research Director
    static let daichi = ext("daichi", "Daichi Fukuda", "daichi.fukuda@wideworldimporters.com", 0.48) // Logistics Coordinator
    static let henry = ext("henry", "Henry Brill", "henry.brill@relecloud.com", 0.61)                // Technical Account Manager
    static let laurence = ext("laurence", "Laurence Gilbertson", "laurence.gilbertson@adatum.com", 0.29) // Audit Partner
    static let marie = ext("marie", "Marie Beaudouin", "marie.beaudouin@southridgevideo.com", 0.99)  // Producer
    static let johnie = ext("johnie", "Johnie McConnell", "johnie.mcconnell@firstupconsultants.com", 0.20) // Recruiter
    static let elliot = ext("elliot", "Elliot Woodward", "elliot.woodward@bellowscollege.com", 0.41) // Professor
    static let isaac = ext("isaac", "Isaac Fielder", "isaac.fielder@alpineskihouse.com", 0.56)       // Events Manager
    static let bryan = ext("bryan", "Bryan Wright", "bryan.wright@humongousinsurance.com", 0.04)     // Underwriter
    static let beth = ext("beth", "Beth Davies", "beth.davies@vanarsdelltd.com", 0.79)               // Business Development
    static let munger = ext("munger", "Allan Munger", "allan.munger@lucernepublishing.com", 0.32)    // Reporter
    static let cameron = ext("cameron", "Cameron Evans", "cameron.evans@outlook.com", 0.67)          // Candidate

    // MARK: Microsoft 365 and Contoso systems
    static let teams = ext("teams", "Microsoft Teams", "noreply@email.teams.microsoft.com", 0.69)
    static let sharepoint = ext("sharepoint", "SharePoint", "no-reply@sharepointonline.com", 0.49)
    static let onedrive = ext("onedrive", "OneDrive", "no-reply@onedrive.com", 0.59)
    static let viva = ext("viva", "Viva Insights", "viva-noreply@microsoft.com", 0.54)
    static let engage = ext("engage", "Viva Engage", "notifications@engage.mail.microsoft", 0.63)
    static let planner = ext("planner", "Planner", "noreply@planner.office365.com", 0.36)
    static let powerbi = ext("powerbi", "Power BI", "no-reply-powerbi@microsoft.com", 0.14)
    static let devops = ext("devops", "Azure DevOps", "azuredevops@microsoft.com", 0.60)
    static let quarantine = ext("quarantine", "Quarantine", "quarantine@messaging.microsoft.com", 0.01)
    static let contosoLife = contoso("contosolife", "Contoso Life", "contosolife", 0.89)
    static let itDesk = contoso("itdesk", "Contoso IT Service Desk", "servicedesk", 0.51)
    static let secOps = contoso("secops", "Contoso Security", "security-noreply", 0.00)
    static let expenses = contoso("expenses", "Contoso Expenses", "expenses-noreply", 0.31)
    static let hr = contoso("hr", "Contoso HR", "hr-noreply", 0.06)
    static let payroll = contoso("payroll", "Contoso Payroll", "payroll-noreply", 0.38)
    static let learning = contoso("learning", "Contoso Learning", "learning-noreply", 0.74)
    static let facilities = contoso("facilities", "Contoso Facilities", "facilities", 0.26)
    static let esign = contoso("esign", "Contoso eSign", "esign-noreply", 0.66)

    // MARK: Outside services
    static let travel = ext("travel", "Margie's Travel", "itineraries@margiestravel.com", 0.46)
    static let airline = ext("airline", "Blue Yonder Airlines", "trips@blueyonderairlines.com", 0.58)
    static let lamna = ext("lamna", "Lamna Healthcare", "benefits@lamnahealthcare.com", 0.43)
    static let woodgroveCard = ext("woodgrovecard", "Woodgrove Bank", "alerts@woodgrovebank.com", 0.53)
    static let messenger = ext("messenger", "Consolidated Messenger", "tracking@consolidatedmessenger.com", 0.11)
    static let lucerneBrief = ext("lucernebrief", "The Lucerne Brief", "newsletter@lucernepublishing.com", 0.71)
    static let gdi = ext("gdi", "Graphic Design Institute", "events@graphicdesigninstitute.com", 0.84)
    static let fourthCoffee = ext("fourthcoffee", "Fourth Coffee", "orders@fourthcoffee.com", 0.07)
    static let coho = ext("coho", "Coho Winery", "orders@cohowinery.com", 0.96)
    static let relecloudStatus = ext("relecloudstatus", "Relecloud Status", "status@relecloud.com", 0.61)
    static let litwareBilling = ext("litwarebilling", "Litware Billing", "billing@litwareinc.com", 0.86)
    static let alpine = ext("alpine", "Alpine Ski House", "reservations@alpineskihouse.com", 0.56)

    // MARK: Junk senders
    static let phish1 = ext("phish1", "IT Helpdesk", "helpdesk@contoso-support.example", 0.00)
    static let phish2 = ext("phish2", "Rewards Center", "claims@gift-rewards.example", 0.17)
    static let spam1 = ext("spam1", "LeadGenius Pro", "sales@leadgenius.example", 0.39)
    static let spam2 = ext("spam2", "Expo Attendee Lists", "lists@expo-data.example", 0.23)
}
