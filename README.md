#CashAppCodingChallenge
_The following is a High Level Overview of the implementation of the CashApp iOS Exercise by Theron (TJ) Jones.

##Structure

CashAppCodingChallenge
    ├──Core/ (MODULE)
    ├   └── StockFetcher.swift
    ├──Stock Feature/ (MODULE)
    ├   ├── Views/ 
    ├   ├    └── ListView.swift
    ├   ├    └── DetailView.swift
    ├   ├    └── Subviews/
    ├   ├         └── LabelValueView.swift
    ├   ├         └── PositionRowView.swift
    ├   ├         └── LoadingView.swift
    ├   ├── Models/
    ├   ├    └── Stock.swift
    ├   └── ViewModels/ 
    ├        └── StockViewModel.swift
    ├
    ├──Stock API/ (MODULE)
        └── RemoteStockFetcher.swift 


##Necessary iOS version and Running Instructions:
iOS 17+ (Observation) is necessary. Open the project, choose an iPhone simulator
destination (ie: iPhone 15) and click Run.           

                                                                    
##Design Patterns & Choices
###MVVM

_Model:
- Clear data structures ('Portfolio', 'Stock') that represent the domain model of the app.

_View:
- SwiftUI views ('ListView' and 'DetailView') and subviews are responsible for displaying the data and handling user interactions.

_ViewModel:
- The 'StockViewModel' acts as the bridge between the model and the views.
- It fetches data from the 'RemoteStockFetcher', processes it, and exposes the necessary information to the views (e.g., stocks, isLoading).
- It also handles errors that might occur during data fetching, updating the UI state accordingly.
- It encapsulates the presentation logic, making decisions about what data to display and how to display it.

###Elements of other patterns:
_Dependency Injection: 
- The 'StockViewModel' depends on the 'StockFetcher' to provide the data. The 'StockFetcher' protocol is the initial boundary layer with interfaces and data types only; it's a contract for fetching stock data. This enforces a clean separation of concerns and API agnosticism, along with leaving room for future flexibility for integration with different stock data providers.
- The preferred method of testing by the interception of requests via the 'URLProtocol' class was utilized by making the URLSession of the 'RemoteStockFetcher' injectable via its initializer.
_Observable Pattern (Observation Framework): 
- The @Observable macro from the Observation framework is used to make the 'StockViewModel' and 'RemoteStockFetcher' classes observable. This allows for automatic UI updates whenever the data changes, promoting a reactive and responsive user experience.
_Repository Pattern (Data Access Layer): 
- The 'RemoteStockFetcher' acts as a repository by encapsulating the logic for fetching stock data from the CashApp API.


##Notes
###TradeOffs

_Keeping the URL privately in 'RemoteStockFetcher' 
I chose to keep the URL privately in 'RemoteStockFetcher' in order to keep responsibilities self-contained and the 'StockViewModel'’s focus on managing the UI state and coordinating data interactions. Injecting the URL into 'RemoteStockFetcher' through its initializer was considered, though ultimately fetching stock data from a different API or source should only requires a small update to the URL within the 'RemoteStockFetcher', and keeping the URL private within the fetcher aligns with good encapsulation principles. It is not necessary for the 'StockViewModel' model to know about the specific URL format or structure; it just needs to know that the fetcher can retrieve the data. Overall, I feel comfortable modifying, maintaining, and extending this code.


###General

'ListView.swift'
- Improved readability and modularity 
- Extracted subviews into separate components
- Shows UI alerts based on thrown errors in fetching data.
- Optimized creation of destination views with use of 'NavigationLink'.

'RemoteStockFetcher.swift'
- Error Handling
- Inside fetchData, specific error types are caught and wrapped in the corresponding 'DataFetcherError' case before being thrown, making it easier for the caller to understand and handle the error appropriately.

'StockViewModel.swift'
- The single source of truth for the stock data.

'CashAppCodingChallengeTests.swift'
- URL Loading System leveraged to intercept and handle requests with 'URLProtocol'.

###Time Spent
Approx 4 hours
