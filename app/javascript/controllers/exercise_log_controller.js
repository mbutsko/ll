import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "exerciseId", "value", "unitLabel", "selectedName", "weightField", "weightInput"]
  static values = { lastValues: Object, lastWeights: Object }

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

    const url = `/api/exercises/search.json?q=${encodeURIComponent(q)}`
    const response = await fetch(url)
    const exercises = await response.json()
    this.selectedIndex = -1
    this.renderResults(exercises)
  }

  renderResults(exercises) {
    if (exercises.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-center text-sm text-gray-400">No exercises found</div>`
    } else {
      this.resultsTarget.innerHTML = exercises.map((e, i) =>
        `<div class="mx-1.5 px-2.5 py-2 text-sm text-gray-700 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors flex items-center justify-between"
              data-index="${i}"
              data-id="${e.id}"
              data-name="${this.escapeHtml(e.name)}"
              data-exercise-type="${e.exercise_type}"
              data-unit-label="${e.unit_label}"
              data-action="mousedown->exercise-log#selectResult">
          <span>${this.escapeHtml(e.name)}</span>
          <span class="text-xs text-gray-400">${e.unit_label}</span>
        </div>`
      ).join("") + `<div class="h-1"></div>`
    }
    this.resultsTarget.classList.remove("hidden")
  }

  selectResult(event) {
    event.preventDefault()
    const el = event.currentTarget
    this.selectExercise(el.dataset.id, el.dataset.name, el.dataset.unitLabel, el.dataset.exerciseType)
  }

  selectExercise(id, name, unitLabel, exerciseType) {
    this.exerciseIdTarget.value = id
    this.selectedNameTarget.textContent = name
    this.selectedNameTarget.classList.remove("hidden")
    this.unitLabelTarget.textContent = unitLabel
    this._selectedType = exerciseType
    const lastValue = this.lastValuesValue[id]
    if (lastValue != null) {
      this.valueTarget.value = lastValue
    }
    if (exerciseType === "reps" && this.hasWeightFieldTarget) {
      this.weightFieldTarget.classList.remove("hidden")
      const lastWeight = this.lastWeightsValue[id]
      if (lastWeight != null) {
        this.weightInputTarget.value = lastWeight
      }
    } else if (this.hasWeightFieldTarget) {
      this.weightFieldTarget.classList.add("hidden")
      this.weightInputTarget.value = ""
    }
    this.inputTarget.value = ""
    this.inputTarget.classList.add("hidden")
    this.close()
    this.valueTarget.focus()
  }

  clearSelection() {
    this.exerciseIdTarget.value = ""
    this.selectedNameTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.unitLabelTarget.textContent = ""
    if (this.hasWeightFieldTarget) {
      this.weightFieldTarget.classList.add("hidden")
      this.weightInputTarget.value = ""
    }
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
          this.selectExercise(el.dataset.id, el.dataset.name, el.dataset.unitLabel, el.dataset.exerciseType)
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
