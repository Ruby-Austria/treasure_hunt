import { Controller } from "@hotwired/stimulus"

// Stats Counter Controller
// Fetches platform stats from API and animates count-up effect
export default class extends Controller {
  static targets = ["hunts", "clues", "locations", "cities"]
  static values = {
    url: { type: String, default: "/stats.json" },
    duration: { type: Number, default: 2000 }, // Animation duration in ms
    updateInterval: { type: Number, default: 30000 } // Update every 30 seconds
  }

  connect() {
    this.fetchAndAnimate()

    // Optional: Auto-refresh stats every 30 seconds
    if (this.updateIntervalValue > 0) {
      this.intervalId = setInterval(() => {
        this.fetchAndAnimate()
      }, this.updateIntervalValue)
    }
  }

  disconnect() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
    }
  }

  async fetchAndAnimate() {
    try {
      const response = await fetch(this.urlValue)
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()

      // Animate each counter
      this.animateCounter(this.huntsTarget, data.hunts)
      this.animateCounter(this.cluesTarget, data.clues)
      this.animateCounter(this.locationsTarget, data.locations)
      this.animateCounter(this.citiesTarget, data.cities)
    } catch (error) {
      console.error("Failed to fetch stats:", error)
      // Fallback: Show placeholders
      this.showFallback()
    }
  }

  animateCounter(element, targetValue) {
    const startValue = parseInt(element.textContent.replace(/,/g, "")) || 0
    const duration = this.durationValue
    const startTime = performance.now()

    const animate = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)

      // Easing function (ease-out cubic)
      const easeOut = 1 - Math.pow(1 - progress, 3)

      const currentValue = Math.floor(startValue + (targetValue - startValue) * easeOut)
      element.textContent = this.formatNumber(currentValue)

      if (progress < 1) {
        requestAnimationFrame(animate)
      } else {
        element.textContent = this.formatNumber(targetValue)
      }
    }

    requestAnimationFrame(animate)
  }

  formatNumber(num) {
    return num.toLocaleString("en-US")
  }

  showFallback() {
    // Show placeholder values if API fails
    this.huntsTarget.textContent = "---"
    this.cluesTarget.textContent = "---"
    this.locationsTarget.textContent = "---"
    this.citiesTarget.textContent = "---"
  }
}
