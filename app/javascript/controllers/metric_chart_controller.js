import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

export default class extends Controller {
  static targets = ["canvas"]
  static values = { data: Array, range: String, unit: String, label: String, fetchUrl: String }

  connect() {
    this.renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  renderChart() {
    if (this.chart) {
      this.chart.destroy()
    }

    const data = this.dataValue
    if (!data.length) return

    const labelCount = data.length
    const maxTicks = 12
    const unit = this.unitValue
    const label = this.labelValue

    const ctx = this.canvasTarget.getContext("2d")
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: data.map(d => d.date),
        datasets: [
          {
            label: label,
            data: data.map(d => d.value),
            borderColor: "rgb(59, 130, 246)",
            backgroundColor: "rgba(59, 130, 246, 0.1)",
            borderWidth: 2,
            pointRadius: labelCount > 90 ? 0 : 3,
            pointHoverRadius: 5,
            tension: 0,
            fill: true
          },
          {
            label: "7-Day Avg",
            data: data.map(d => d.avg_7d),
            borderColor: "rgb(245, 158, 11)",
            borderWidth: 2,
            borderDash: [6, 3],
            pointRadius: 0,
            pointHoverRadius: 4,
            tension: 0.3,
            fill: false
          },
          {
            label: "30-Day Avg",
            data: data.map(d => d.avg_30d),
            borderColor: "rgb(239, 68, 68)",
            borderWidth: 2,
            borderDash: [6, 3],
            pointRadius: 0,
            pointHoverRadius: 4,
            tension: 0.3,
            fill: false
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: "index",
          intersect: false
        },
        scales: {
          x: {
            ticks: {
              maxRotation: 45,
              autoSkip: true,
              maxTicksLimit: maxTicks
            },
            grid: { display: false }
          },
          y: {
            title: { display: true, text: unit },
            grid: { color: "rgba(0, 0, 0, 0.05)" }
          }
        },
        plugins: {
          legend: {
            position: "top",
            labels: { usePointStyle: true, padding: 16 }
          },
          tooltip: {
            backgroundColor: "rgba(0, 0, 0, 0.8)",
            padding: 12,
            cornerRadius: 8
          }
        }
      }
    })
  }

  async changeRange(event) {
    const range = event.currentTarget.dataset.range
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    this.element.querySelectorAll("button[data-action]").forEach(btn => {
      if (btn.dataset.range === range) {
        btn.className = "px-4 py-2 text-sm font-medium rounded-lg transition bg-blue-600 text-white"
      } else {
        btn.className = "px-4 py-2 text-sm font-medium rounded-lg transition bg-white text-gray-600 border border-gray-300 hover:bg-gray-50"
      }
    })

    const response = await fetch(`${this.fetchUrlValue}.json?range=${range}`, {
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken
      }
    })

    if (response.ok) {
      const json = await response.json()
      this.dataValue = json.chart_data
      this.renderChart()
    }
  }

  dataValueChanged() {
    if (this.chart) {
      this.renderChart()
    }
  }
}
