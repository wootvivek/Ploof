import Foundation

/// Synthetic people for the proof of concept. Edit freely.
///
/// The mailbox belongs to Vivek, who leads product for "Sandpiper", a fictional release of Outlook
/// Mobile, on a fictional Outlook Mobile team at Microsoft. Everything here is made up: the team, the
/// roles, the release and its numbers. The names are the fictitious people and companies Microsoft
/// publishes for demos and documentation, so nobody is mistaken for a real colleague or customer.
/// Addresses use first.last@microsoft.com and are not real mailboxes.
enum MockPeople {
    private static func team(_ id: String, _ name: String, _ hue: Double) -> Person {
        let address = name.lowercased().split(separator: " ").joined(separator: ".")
        return Person(id: id, name: name, email: "\(address)@microsoft.com", hue: hue)
    }

    private static func system(_ id: String, _ name: String, _ alias: String, _ hue: Double) -> Person {
        Person(id: id, name: name, email: "\(alias)@microsoft.com", hue: hue)
    }

    private static func ext(_ id: String, _ name: String, _ email: String, _ hue: Double) -> Person {
        Person(id: id, name: name, email: email, hue: hue)
    }

    static let me = Person(id: "me", name: "Vivek", email: "vivek.demo@microsoft.com", hue: 0.68)

    // MARK: Leadership
    static let patti = team("patti", "Patti Fernandez", 0.95)        // Corporate Vice President
    static let erik = team("erik", "Erik Nason", 0.58)               // Partner Director of Product, Vivek's manager
    static let carlos = team("carlos", "Carlos Slattery", 0.10)      // Finance Director
    static let miriam = team("miriam", "Miriam Graham", 0.83)        // Director, Product Marketing and Field
    static let nestor = team("nestor", "Nestor Wilke", 0.30)         // Director, Live Site
    static let lee = team("lee", "Lee Gu", 0.47)                     // Director of Engineering, Android

    // MARK: Outlook Mobile team
    static let megan = team("megan", "Megan Bowen", 0.90)            // Product Marketing Manager
    static let alexW = team("alexw", "Alex Wilber", 0.40)            // Marketing Coordinator
    static let adele = team("adele", "Adele Vance", 0.02)            // Customer Success, Retail
    static let allan = team("allan", "Allan Deyoung", 0.55)          // Tenant Admin
    static let christie = team("christie", "Christie Cline", 0.78)   // Procurement
    static let debra = team("debra", "Debra Berger", 0.13)           // Executive Assistant to Patti
    static let diego = team("diego", "Diego Siciliani", 0.07)        // HR Business Partner
    static let emily = team("emily", "Emily Braun", 0.73)            // Finance Analyst
    static let enrico = team("enrico", "Enrico Cattaneo", 0.62)      // Attorney
    static let grady = team("grady", "Grady Archie", 0.35)           // Designer
    static let henrietta = team("henrietta", "Henrietta Mueller", 0.87) // iOS Engineer
    static let irvin = team("irvin", "Irvin Sayers", 0.52)           // Release Program Manager
    static let isaiah = team("isaiah", "Isaiah Langer", 0.16)        // Customer Engineer
    static let johanna = team("johanna", "Johanna Lorenz", 0.98)     // Senior Engineer, Sync
    static let joni = team("joni", "Joni Sherman", 0.80)             // Paralegal
    static let lidia = team("lidia", "Lidia Holloway", 0.93)         // Product Manager on Vivek's team
    static let lynne = team("lynne", "Lynne Robbins", 0.22)          // Planner
    static let pradeep = team("pradeep", "Pradeep Gupta", 0.44)      // Finance Analyst, cost modeling
    static let kat = team("kat", "Kat Larsson", 0.75)                // Product Manager on Vivek's team
    static let daisy = team("daisy", "Daisy Phillips", 0.05)         // Data Analyst
    static let elvia = team("elvia", "Elvia Atkins", 0.27)           // Customer Success
    static let kevin = team("kevin", "Kevin Sturgis", 0.60)          // Security and Compliance
    static let mona = team("mona", "Mona Kane", 0.85)                // UX Researcher
    static let colin = team("colin", "Colin Ballinger", 0.50)        // Engineering Manager, iOS
    static let robin = team("robin", "Robin Counts", 0.00)           // Support Escalation Lead
    static let amanda = team("amanda", "Amanda Brady", 0.88)         // Recruiter
    static let cecil = team("cecil", "Cecil Folk", 0.33)             // Partner Dependencies
    static let wanda = team("wanda", "Wanda Howard", 0.70)           // Communications
    static let tim = team("tim", "Tim Deboer", 0.18)                 // Quality Lead
    static let babak = team("babak", "Babak Shammas", 0.42)          // Data Scientist
    static let kayo = team("kayo", "Kayo Miwa", 0.97)                // Market Lead, Japan

    // MARK: Customers and prospects
    static let charlotte = ext("charlotte", "Charlotte Waltson", "charlotte.waltson@northwindtraders.com", 0.57) // VP Store Operations
    static let aadi = ext("aadi", "Aadi Kapoor", "aadi.kapoor@northwindtraders.com", 0.12)                       // Procurement
    static let hillary = ext("hillary", "Hillary Reyes", "hillary.reyes@northwindtraders.com", 0.82)             // IT Security
    static let ray = ext("ray", "Ray Tanaka", "ray.tanaka@adventure-works.com", 0.37)                            // Head of Field Operations
    static let kristin = ext("kristin", "Kristin Patterson", "kristin.patterson@adventure-works.com", 0.91)      // Program Manager
    static let will = ext("will", "Will Little", "will.little@tailspintoys.com", 0.24)                           // Store Technology
    static let krystal = ext("krystal", "Krystal McKinney", "krystal.mckinney@wingtiptoys.com", 0.77)            // Store Technology
    static let robert = ext("robert", "Robert Tolbert", "robert.tolbert@woodgrovebank.com", 0.53)                // Workplace Technology
    static let bryan = ext("bryan", "Bryan Wright", "bryan.wright@humongousinsurance.com", 0.04)                 // IT Director

    // MARK: Vendors, partners and advisers
    static let mauricio = ext("mauricio", "Mauricio August", "mauricio.august@fabrikam.com", 0.08)   // Account Director, device test lab
    static let lydia = ext("lydia", "Lydia Bauer", "lydia.bauer@fabrikam.com", 0.65)                 // Quality Engineer, device test lab
    static let celeste = ext("celeste", "Celeste Burton", "celeste.burton@litwareinc.com", 0.86)     // Account Executive, crash analytics
    static let serena = ext("serena", "Serena Davis", "serena.davis@proseware.com", 0.94)            // Creative Director
    static let miguel = ext("miguel", "Miguel Garcia", "miguel.garcia@proseware.com", 0.15)          // Account Lead
    static let katri = ext("katri", "Katri Ahokas", "katri.ahokas@treyresearch.net", 0.72)           // Research Director
    static let daichi = ext("daichi", "Daichi Fukuda", "daichi.fukuda@wideworldimporters.com", 0.48) // Localization Coordinator
    static let henry = ext("henry", "Henry Brill", "henry.brill@relecloud.com", 0.61)                // Technical Account Manager, push relay
    static let laurence = ext("laurence", "Laurence Gilbertson", "laurence.gilbertson@adatum.com", 0.29) // Accessibility Audit Lead
    static let marie = ext("marie", "Marie Beaudouin", "marie.beaudouin@southridgevideo.com", 0.99)  // Producer
    static let johnie = ext("johnie", "Johnie McConnell", "johnie.mcconnell@firstupconsultants.com", 0.20) // Recruiter
    static let elliot = ext("elliot", "Elliot Woodward", "elliot.woodward@bellowscollege.com", 0.41) // Professor
    static let isaac = ext("isaac", "Isaac Fielder", "isaac.fielder@alpineskihouse.com", 0.56)       // Events Manager
    static let beth = ext("beth", "Beth Davies", "beth.davies@blueyonderairlines.com", 0.79)         // Business Development
    static let munger = ext("munger", "Allan Munger", "allan.munger@lucernepublishing.com", 0.32)    // Reporter
    static let cameron = ext("cameron", "Cameron Evans", "cameron.evans@outlook.com", 0.67)          // Candidate

    // MARK: Microsoft 365 and internal systems
    static let teams = ext("teams", "Microsoft Teams", "noreply@email.teams.microsoft.com", 0.69)
    static let sharepoint = ext("sharepoint", "SharePoint", "no-reply@sharepointonline.com", 0.49)
    static let onedrive = ext("onedrive", "OneDrive", "no-reply@onedrive.com", 0.59)
    static let viva = ext("viva", "Viva Insights", "viva-noreply@microsoft.com", 0.54)
    static let engage = ext("engage", "Viva Engage", "notifications@engage.mail.microsoft", 0.63)
    static let planner = ext("planner", "Planner", "noreply@planner.office365.com", 0.36)
    static let powerbi = ext("powerbi", "Power BI", "no-reply-powerbi@microsoft.com", 0.14)
    static let devops = ext("devops", "Azure DevOps", "azuredevops@microsoft.com", 0.60)
    static let quarantine = ext("quarantine", "Quarantine", "quarantine@messaging.microsoft.com", 0.01)
    static let teamNews = system("teamnews", "Team News", "outlook-mobile-news", 0.89)
    static let itDesk = system("itdesk", "IT Service Desk", "it-servicedesk-noreply", 0.51)
    static let secOps = system("secops", "Security", "security-noreply", 0.00)
    static let expenses = system("expenses", "Expenses", "expenses-noreply", 0.31)
    static let hr = system("hr", "HR", "hr-noreply", 0.06)
    static let payroll = system("payroll", "Payroll", "payroll-noreply", 0.38)
    static let learning = system("learning", "Learning", "learning-noreply", 0.74)
    static let facilities = system("facilities", "Facilities", "facilities-noreply", 0.26)
    static let esign = system("esign", "eSign", "esign-noreply", 0.66)

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
    static let phish1 = ext("phish1", "IT Helpdesk", "helpdesk@account-verify.example", 0.00)
    static let phish2 = ext("phish2", "Rewards Center", "claims@gift-rewards.example", 0.17)
    static let spam1 = ext("spam1", "LeadGenius Pro", "sales@leadgenius.example", 0.39)
    static let spam2 = ext("spam2", "Summit Attendee Lists", "lists@summit-data.example", 0.23)
}
