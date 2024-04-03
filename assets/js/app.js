// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")


function scrollToBottom(element) {

    console.log("-----")
    console.log(element)
    console.log("page_".concat(localStorage.getItem("page")))
    console.log(readerState())

    if (element.id != "page_".concat(localStorage.getItem("page")) && readerState == "sliding") {

        content_el = document.getElementById("content")
        window.scrollTo(0, element.offsetTop - content_el.offsetTop);
    }
 }

window.addEventListener("phx:scrollto", phxUpdateListener)

function phxUpdateListener(e) {
    scrollToBottom(document.getElementById(e.detail.page))
  }


// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

let Hooks = {}

Hooks.MyScroller = {
 mounted(){

    monitorScrolling(this)

 },

  updated() {
    monitorScrolling(this)

  }
}


function monitorScrolling(relay) {
    let options = {
        root: relay.ele, // relative to document viewport 
        rootMargin: '20px', // margin around root. Values are similar to css property. Unitless values not allowed 
        threshold: 0.6 // visible amount of item shown in relation to root 
    };

    scrollElements = document.querySelectorAll('[id^=page_]');

    const observers = {}

    for (var i = 0; i < scrollElements.length; ++i) {
        const observerName = scrollElements[i]
         
        observers[observerName] = new IntersectionObserver (
            entries => { 
                entries.forEach(entry => {


                    if (Math.abs(document.getElementById("reader_progress").value - entry.target.id.slice(entry.target.id.indexOf("_") + 1)) > 1) {
                                        console.log("value")        
                    console.log(document.getElementById("reader_progress").value)
                    console.log("incoming")
                    console.log(entry.target.id.slice(entry.target.id.indexOf("_") + 1))
                    }


                    if (entry.isIntersecting && Math.abs(document.getElementById("reader_progress").value - entry.target.id.slice(entry.target.id.indexOf("_") + 1)) > 1) {
                        document.getElementById("reader_progress").value = entry.target.id.slice(entry.target.id.indexOf("_") + 1);
                        console.log(document.getElementById("reader_progress").value);
                        localStorage.setItem('page', document.getElementById("reader_progress").value);
                        relay.pushEvent("scrollto", {position: entry.target.id.slice(entry.target.id.indexOf("_") + 1)})
                    }
                    
                })
            }, options);
        
        observers[observerName].observe(scrollElements[i])
    }
}

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

