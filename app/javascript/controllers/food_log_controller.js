import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "foodId", "value", "unitSelect", "selectedName"]

  connect() {
    this.selectedIndex = -1
    this._onClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this._onClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._onClickOutside)
    clearTimeout(this._debounce)
  }

  onInput() {
    clearTimeout(this._debounce)
    this._debounce = setTimeout(() => this.fetchResults(), 150)
  }

  async fetchResults() {
    const q = this.inputTarget.value.trim()
    if (q === "") {
      this.close()
      return
    }

    const url = `/api/foods/search.json?q=${encodeURIComponent(q)}`
    const response = await fetch(url)
    const foods = await response.json()
    this.selectedIndex = -1
    this.renderResults(foods)
  }

  renderResults(foods) {
    if (foods.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-center text-sm text-gray-400">No foods found</div>`
    } else {
      this.resultsTarget.innerHTML = foods.map((f, i) =>
        `<div class="mx-1.5 px-2.5 py-2 text-sm text-gray-700 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors flex items-center justify-between"
              data-index="${i}"
              data-id="${f.id}"
              data-name="${this.escapeHtml(f.name)}"
              data-default-unit="${f.default_unit}"
              data-action="mousedown->food-log#selectResult">
          <span>${this.escapeHtml(f.name)}</span>
          <span class="text-xs text-gray-400">${f.default_unit}</span>
        </div>`
      ).join("") + `<div class="h-1"></div>`
    }
    this.resultsTarget.classList.remove("hidden")
  }

  selectResult(event) {
    event.preventDefault()
    const el = event.currentTarget
    this.selectFood(el.dataset.id, el.dataset.name, el.dataset.defaultUnit)
  }

  selectFood(id, name, defaultUnit) {
    this.foodIdTarget.value = id
    this.selectedNameTarget.textContent = name
    this.selectedNameTarget.classList.remove("hidden")
    this.unitSelectTarget.value = defaultUnit
    this.inputTarget.value = ""
    this.inputTarget.classList.add("hidden")
    this.close()
    this.valueTarget.focus()
  }

  clearSelection() {
    this.foodIdTarget.value = ""
    this.selectedNameTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.focus()
  }

  onKeydown(event) {
    if (!this.resultsTarget || this.resultsTarget.classList.contains("hidden")) {
      if (event.key === "ArrowDown" || event.key === "Enter") {
        this.fetchResults()
      }
      return
    }

    const items = this.resultsTarget.querySelectorAll("[data-id]")
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
          const el = items[this.selectedIndex]
          this.selectFood(el.dataset.id, el.dataset.name, el.dataset.defaultUnit)
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
    setTimeout(() => this.close(), 150)
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
