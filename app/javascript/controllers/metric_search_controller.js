import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "shortcutHint"]

  connect() {
    this.selectedIndex = -1
    this._onClickOutside = this.clickOutside.bind(this)
    this._onGlobalKeydown = this.globalKeydown.bind(this)
    document.addEventListener("click", this._onClickOutside)
    document.addEventListener("keydown", this._onGlobalKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this._onClickOutside)
    document.removeEventListener("keydown", this._onGlobalKeydown)
    clearTimeout(this._debounce)
  }

  globalKeydown(event) {
    if (event.key === "/" && !this.isInputFocused()) {
      event.preventDefault()
      // Focus on next frame to avoid "/" leaking into the input
      requestAnimationFrame(() => {
        this.inputTarget.focus()
        this.inputTarget.value = ""
      })
    }
  }

  isInputFocused() {
    const active = document.activeElement
    return active && (active.tagName === "INPUT" || active.tagName === "TEXTAREA" || active.isContentEditable)
  }

  onInput() {
    clearTimeout(this._debounce)
    this._debounce = setTimeout(() => this.fetchResults(), 150)
    if (this.hasShortcutHintTarget) this.shortcutHintTarget.classList.add("hidden")
  }

  async fetchResults() {
    const q = this.inputTarget.value.trim()
    const url = `/api/metrics/search.json?q=${encodeURIComponent(q)}`
    const response = await fetch(url)
    const metrics = await response.json()
    this.selectedIndex = -1
    this.renderResults(metrics)
  }

  renderResults(metrics) {
    if (metrics.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-6 text-center">
          <svg class="mx-auto h-6 w-6 text-gray-300 mb-2" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
          </svg>
          <p class="text-sm text-gray-400">No metrics found</p>
        </div>`
    } else {
      this.resultsTarget.innerHTML = `
        <div class="px-3 pt-2 pb-1">
          <p class="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Metrics</p>
        </div>` +
        metrics.map((m, i) =>
          `<a href="/measurements/${m.slug}"
              class="flex items-center gap-2.5 mx-1.5 px-2.5 py-2 text-sm text-gray-700 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors"
              data-index="${i}"
              data-action="mousedown->metric-search#selectResult">
            <span class="flex-shrink-0 w-6 h-6 rounded-md bg-blue-50 text-blue-500 flex items-center justify-center text-xs font-semibold">${this.escapeHtml(m.name.charAt(0).toUpperCase())}</span>
            <span class="truncate">${this.escapeHtml(m.name)}</span>
          </a>`
        ).join("") +
        `<div class="h-1.5"></div>`
    }
    this.resultsTarget.classList.remove("hidden")
  }

  selectResult(event) {
    event.preventDefault()
    window.location.href = event.currentTarget.getAttribute("href")
  }

  onKeydown(event) {
    if (!this.resultsTarget || this.resultsTarget.classList.contains("hidden")) {
      if (event.key === "ArrowDown" || event.key === "Enter") {
        this.fetchResults()
      }
      return
    }

    const items = this.resultsTarget.querySelectorAll("a")
    if (items.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.highlightItem(items)
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.highlightItem(items)
        break
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
          window.location.href = items[this.selectedIndex].getAttribute("href")
        }
        break
      case "Escape":
        this.close()
        this.inputTarget.blur()
        break
    }
  }

  highlightItem(items) {
    items.forEach((item, i) => {
      if (i === this.selectedIndex) {
        item.classList.add("bg-gray-100")
        item.scrollIntoView({ block: "nearest" })
      } else {
        item.classList.remove("bg-gray-100")
      }
    })
  }

  onBlur() {
    setTimeout(() => {
      this.close()
      if (this.hasShortcutHintTarget && this.inputTarget.value === "") {
        this.shortcutHintTarget.classList.remove("hidden")
      }
    }, 150)
  }

  close() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.add("hidden")
    }
    this.selectedIndex = -1
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
