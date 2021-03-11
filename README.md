# HybridConsentExample
Example showing how to support bidirectional consent management within a webview using the Tealium Swift SDK

## Usage
This is a simple (and ugly) SwiftUI app showing how consent can be shared between a native app and a WebView within that app. Updates in the app are reflected in the webview and vice-versa.

## Changes required in Tealium iQ
The Consent Manager in Tealium iQ needs a couple of small changes in order to support consent syncing:

* The `closePrompt` function in the JS template has been modified to:

```
    var closePrompt = function () {
      // calls the syncConsent function after a short delay to make sure the categories have been set in the cookie
      if (window.syncConsent) {
          setTimeout(function (){
              window.syncConsent(utag.gdpr.getSelectedCategories().join());
          },10);
        
      }
    $modal.style.display = "none";
  };
```
  
* An DOM Ready-scoped JS extension has been added to the Tealium iQ profile to process the query parameters and display the consent prompt as needed:

```
  // Type your JavaScript code here...

function getQueryParam(param) {
    var query = window.location.search.substring(1);
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');
        if (decodeURIComponent(pair[0]) == param) {
            return decodeURIComponent(pair[1]);
        }
    }
}

var consent_categories_qp = getQueryParam("consent_categories");

if (consent_categories_qp.length > 0) {
    consent_categories_qp = consent_categories_qp.split(",");
    utag.track("update_consent_cookie", {"consent_categories": consent_categories_qp});
    utag.gdpr.showConsentPreferences();
} else if (consent_categories_qp === "") {
    utag.track("update_consent_cookie", {"consent_categories": []});
    utag.gdpr.showConsentPreferences();
} else {
    utag.gdpr.showConsentPreferences();
}
```

* A Preloader-scoped JS extension has been added to add the "syncConsent" function as early as possible in the load process

```
window.syncConsent = function(categories) {
    if (!categories) {
        return;
    }
    // Android Only:
  if (window.WebViewInterface) {
    window.WebViewInterface.trackView(tealiumEvent, JSON.stringify(data));
    // iOS only:
  } else if (window.webkit
      && window.webkit.messageHandlers
      && window.webkit.messageHandlers.tealium) {
    var message = {
      command: 'syncConsent',
      categories: categories
    };
    window.webkit.messageHandlers.tealium.postMessage(message);
  }
}
```

**This code is for demo purposes only, and does not necessarily follow all best practices. Production code should be thoroughly reviewed and tested.**
