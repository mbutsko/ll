import { Controller } from "@hotwired/stimulus"
import { Chart, registerables, _adapters } from "chart.js"
import {
  toDate, parse, parseISO, format,
  addYears, addQuarters, addMonths, addWeeks, addDays,
  addHours, addMinutes, addSeconds, addMilliseconds,
  differenceInYears, differenceInQuarters, differenceInMonths,
  differenceInWeeks, differenceInDays, differenceInHours,
  differenceInMinutes, differenceInSeconds, differenceInMilliseconds,
  startOfYear, startOfQuarter, startOfMonth, startOfWeek, startOfDay,
  startOfHour, startOfMinute, startOfSecond,
  endOfYear, endOfQuarter, endOfMonth, endOfWeek, endOfDay,
  endOfHour, endOfMinute, endOfSecond
} from "date-fns"

Chart.register(...registerables)

const STARTS = { second: startOfSecond, minute: startOfMinute, hour: startOfHour, day: startOfDay, week: startOfWeek, month: startOfMonth, quarter: startOfQuarter, year: startOfYear }
const ENDS = { second: endOfSecond, minute: endOfMinute, hour: endOfHour, day: endOfDay, week: endOfWeek, month: endOfMonth, quarter: endOfQuarter, year: endOfYear }
const ADDERS = { millisecond: addMilliseconds, second: addSeconds, minute: addMinutes, hour: addHours, day: addDays, week: addWeeks, month: addMonths, quarter: addQuarters, year: addYears }
const DIFFS = { millisecond: differenceInMilliseconds, second: differenceInSeconds, minute: differenceInMinutes, hour: differenceInHours, day: differenceInDays, week: differenceInWeeks, month: differenceInMonths, quarter: differenceInQuarters, year: differenceInYears }

_adapters._date.override({
  formats() { return { datetime: "MMM d, yyyy, h:mm:ss aaaa", millisecond: "h:mm:ss.SSS aaaa", second: "h:mm:ss aaaa", minute: "h:mm aaaa", hour: "ha", day: "MMM d", week: "PP", month: "MMM yyyy", quarter: "'Q'Q - yyyy", year: "yyyy" } },
  parse(value, fmt) {
    if (value == null) return null
    if (typeof value === "number") return value
    if (value instanceof Date) return +value
    if (typeof value === "string") return fmt ? +parse(value, fmt, new Date()) : +parseISO(value)
    return null
  },
  format(time, fmt) { return format(toDate(time), fmt) },
  add(time, amount, unit) { return ADDERS[unit] ? +ADDERS[unit](toDate(time), amount) : time },
  diff(max, min, unit) { return DIFFS[unit] ? DIFFS[unit](toDate(max), toDate(min)) : 0 },
  startOf(time, unit) { return STARTS[unit] ? +STARTS[unit](toDate(time)) : time },
  endOf(time, unit) { return ENDS[unit] ? +ENDS[unit](toDate(time)) : time }
})

// If data points are more than 2 days apart, show a gap in the line
const GAP_THRESHOLD_MS = 2 * 24 * 60 * 60 * 1000

export default class extends Controller {
  static targets = ["canvas"]
  static values = { data: Array, range: String, unit: String, label: String, fetchUrl: String, daily: { type: Boolean, default: false } }

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
    const unit = this.unitValue
    const label = this.labelValue

    const points = data.map(d => ({ x: d.date, y: d.value }))
    const avg7Points = data.map(d => ({ x: d.date, y: d.avg_7d }))
    const avg30Points = data.map(d => ({ x: d.date, y: d.avg_30d }))

    const ctx = this.canvasTarget.getContext("2d")
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        datasets: [
          {
            label: label,
            data: points,
            borderColor: "rgb(59, 130, 246)",
            backgroundColor: "rgba(59, 130, 246, 0.1)",
            borderWidth: 2,
            pointRadius: labelCount > 90 ? 0 : 3,
            pointHoverRadius: 5,
            tension: 0,
            fill: true,
            spanGaps: GAP_THRESHOLD_MS
          },
          ...(this.dailyValue ? [
            {
              label: "7-Day Avg",
              data: avg7Points,
              borderColor: "rgb(245, 158, 11)",
              borderWidth: 2,
              borderDash: [6, 3],
              pointRadius: 0,
              pointHoverRadius: 4,
              tension: 0.3,
              fill: false,
              spanGaps: GAP_THRESHOLD_MS
            },
            {
              label: "30-Day Avg",
              data: avg30Points,
              borderColor: "rgb(239, 68, 68)",
              borderWidth: 2,
              borderDash: [6, 3],
              pointRadius: 0,
              pointHoverRadius: 4,
              tension: 0.3,
              fill: false,
              spanGaps: GAP_THRESHOLD_MS
            }
          ] : [])
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
            type: "time",
            time: {
              unit: this.#timeUnit(data),
              tooltipFormat: "MMM d, yyyy",
              displayFormats: {
                day: "MMM d",
                week: "MMM d",
                month: "MMM yyyy"
              }
            },
            ticks: {
              maxRotation: 45,
              autoSkip: true,
              maxTicksLimit: 12
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

  #timeUnit(data) {
    if (data.length < 2) return "day"
    const first = new Date(data[0].date)
    const last = new Date(data[data.length - 1].date)
    const spanDays = (last - first) / (1000 * 60 * 60 * 24)
    if (spanDays > 365) return "month"
    if (spanDays > 90) return "week"
    return "day"
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
