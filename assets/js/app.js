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

const Hooks = {}

Hooks.ProtectedVideo = {
  mounted() {
    this.playerHost = this.el.querySelector("[data-role='player']")
    this.watermark = this.el.querySelector("[data-role='watermark']")
    this.abortController = new AbortController()

    this.el.addEventListener("contextmenu", event => event.preventDefault())
    this.loadPlayer()
    this.moveWatermark()
    this.watermarkTimer = window.setInterval(() => this.moveWatermark(), 8000)
  },

  destroyed() {
    this.saveProgress?.()
    this.abortController?.abort()
    window.clearInterval(this.watermarkTimer)
  },

  async loadPlayer() {
    try {
      const response = await fetch(this.el.dataset.playbackUrl, {
        credentials: "same-origin",
        headers: {"accept": "application/json"},
        signal: this.abortController.signal
      })

      if (!response.ok) throw new Error(`Playback authorization failed (${response.status})`)

      const {url} = await response.json()
      await customElements.whenDefined("mux-player")

      const player = document.createElement("mux-player")
      player.setAttribute("src", url)
      player.setAttribute("stream-type", "on-demand")
      player.setAttribute("accent-color", "#009d77")
      player.setAttribute("metadata-video-title", this.el.dataset.videoTitle)
      player.setAttribute("metadata-viewer-user-id", this.el.dataset.viewerId)
      player.setAttribute("playsinline", "")
      player.style.width = "100%"
      player.style.height = "100%"

      this.player = player
      this.lastSavedPosition = Number(this.el.dataset.startPosition || 0)
      this.lastSaveAt = 0

      player.addEventListener("loadedmetadata", () => {
        const startPosition = Number(this.el.dataset.startPosition || 0)

        if (startPosition > 0 && startPosition < player.duration) {
          player.currentTime = startPosition
        }
      })

      player.addEventListener("timeupdate", () => {
        const now = Date.now()

        if (
          player.currentTime - this.lastSavedPosition >= 10 ||
          now - this.lastSaveAt >= 15000
        ) {
          this.saveProgress()
        }
      })

      player.addEventListener("ended", () => {
        this.pushEvent("complete-lecture", {lecture_id: this.el.dataset.lectureId})
      })

      this.playerHost.replaceChildren(player)
    } catch (error) {
      if (error.name === "AbortError") return
      this.playerHost.textContent = "This protected video is temporarily unavailable."
      console.error(error)
    }
  },

  saveProgress() {
    if (!this.player || !Number.isFinite(this.player.currentTime)) return

    const position = Math.max(0, Math.floor(this.player.currentTime))
    if (position <= this.lastSavedPosition) return

    this.lastSavedPosition = position
    this.lastSaveAt = Date.now()
    this.pushEvent("video-progress", {
      lecture_id: this.el.dataset.lectureId,
      position_seconds: position
    })
  },

  moveWatermark() {
    if (!this.watermark) return

    const positions = [
      ["6%", "8%"],
      ["58%", "12%"],
      ["10%", "78%"],
      ["54%", "74%"],
      ["34%", "42%"]
    ]
    const [left, top] = positions[Math.floor(Math.random() * positions.length)]
    this.watermark.style.left = left
    this.watermark.style.top = top
  }
}

Hooks.MuxUpload = {
  mounted() {
    this.fileInput = this.el.querySelector("[data-role='file']")
    this.startButton = this.el.querySelector("[data-role='start']")
    this.progress = this.el.querySelector("[data-role='progress']")

    this.startButton.addEventListener("click", () => {
      if (!this.fileInput.files[0]) {
        this.fileInput.setCustomValidity("Choose a video file first.")
        this.fileInput.reportValidity()
        return
      }

      this.fileInput.setCustomValidity("")
      this.startButton.disabled = true
      this.pushEvent("create-upload", {
        filename: this.fileInput.files[0].name,
        content_type: this.fileInput.files[0].type,
        size: this.fileInput.files[0].size
      })
    })

    this.handleEvent("mux-upload-ready", ({url}) => this.upload(url))
    this.handleEvent("mux-check-upload", () => {
      window.clearTimeout(this.statusTimer)
      this.statusTimer = window.setTimeout(() => this.pushEvent("check-upload", {}), 3000)
    })
  },

  destroyed() {
    this.request?.abort()
    window.clearTimeout(this.statusTimer)
  },

  upload(url) {
    const file = this.fileInput.files[0]
    const request = new XMLHttpRequest()
    this.request = request

    request.upload.addEventListener("progress", event => {
      if (!event.lengthComputable) return
      this.progress.style.width = `${Math.round((event.loaded / event.total) * 100)}%`
    })

    request.addEventListener("load", () => {
      if (request.status >= 200 && request.status < 300) {
        this.progress.style.width = "100%"
        this.pushEvent("upload-complete", {})
      } else {
        this.startButton.disabled = false
        console.error(`Mux upload failed (${request.status})`)
      }
    })

    request.addEventListener("error", () => {
      this.startButton.disabled = false
      console.error("Mux upload failed because of a network error")
    })

    request.open("PUT", url)
    request.setRequestHeader("Content-Type", file.type || "application/octet-stream")
    request.send(file)
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
