import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    adventureId: Number,
    allHints: Array,
    revealedHints: Array,
    lastHintRevealedAt: Number,
    cooldownMinutes: { type: Number, default: 30 }
  }

  static targets = [
    "revealHintBtn",
    "hintErrorMessage",
    "hintErrorText",
    "cooldownMessage",
    "cooldownTimer",
    "revealedHintsSection",
    "hintsList",
    "checkLocationBtn",
    "locationStatus",
    "claimSection",
    "claimBtn",
    "debugInfo",
    "debugContent",
    "forceClaimModal",
    "hintsUsedBadge",
    "abandonModal"
  ]

  connect() {
    this.canClaim = false
    this.claimToken = null
    this.cooldownInterval = null
    this.isCheckingLocation = false
    this.lastCheckTime = 0
    this.MIN_CHECK_INTERVAL = 2000

    if (this.allHintsValue?.length > 0) {
      this.checkAndDisableHintButton()
      if (this.lastHintRevealedAtValue) {
        this.startCooldownInterval()
      }
    }
  }

  disconnect() {
    this.clearCooldownInterval()
  }

  // --- Hint System ---

  revealRandomHint() {
    if (!this.hasRevealHintBtnTarget) return

    this.revealHintBtnTarget.disabled = true
    this.revealHintBtnTarget.textContent = "Revealing..."

    this.postJSON(`/adventures/${this.adventureIdValue}/increment_hint_usage`)
      .then(data => this.handleHintResponse(data))
      .catch(() => {
        this.resetHintButton()
        this.showHintError("Error revealing hint. Please try again.")
      })
  }

  handleHintResponse(data) {
    this.resetHintButton()

    if (data.error) {
      this.handleHintError(data)
      return
    }

    this.hideTarget("hintErrorMessage")

    if (data.message === "All hints have been revealed") {
      this.checkAndDisableHintButton()
      return
    }

    if (data.revealed_hints) {
      this.revealedHintsValue = data.revealed_hints
    }

    this.showTarget("revealedHintsSection")

    if (data.hint && this.hasHintsListTarget) {
      const hintItem = document.createElement("li")
      hintItem.className = "text-sm text-gray-700 p-3 bg-white rounded-lg border border-ruby-200"
      hintItem.textContent = data.hint
      this.hintsListTarget.appendChild(hintItem)
    }

    if (data.hints_used !== undefined && this.hasHintsUsedBadgeTarget) {
      const label = data.hints_used === 1 ? "hint" : "hints"
      this.hintsUsedBadgeTarget.textContent = `${data.hints_used} ${label} used`
    }

    if (data.next_hint_available_at) {
      const cooldownMs = this.cooldownMinutesValue * 60 * 1000
      this.lastHintRevealedAtValue = new Date(data.next_hint_available_at).getTime() - cooldownMs
    }

    this.checkAndDisableHintButton()

    if (data.hint && data.next_hint_available_at) {
      this.startCooldownInterval(data.next_hint_available_at)
    }
  }

  handleHintError(data) {
    this.hideTarget("cooldownMessage")

    if (data.cooldown_remaining) {
      this.showTarget("cooldownMessage")
      if (this.hasCooldownTimerTarget && data.cooldown_remaining) {
        this.updateCooldownTimer(data.cooldown_remaining * 1000)
        this.startCooldownInterval(data.next_hint_available_at)
      }
      this.disableHintButton()
    } else {
      if (this.hasHintErrorMessageTarget && this.hasHintErrorTextTarget) {
        this.hintErrorTextTarget.textContent = data.error
        this.showTarget("hintErrorMessage")
      }
    }
  }

  showHintError(message) {
    if (this.hasHintErrorMessageTarget && this.hasHintErrorTextTarget) {
      this.hintErrorTextTarget.textContent = message
      this.showTarget("hintErrorMessage")
    }
  }

  checkCooldown() {
    if (!this.allHintsValue || !this.revealedHintsValue) return

    if (this.revealedHintsValue.length >= this.allHintsValue.length) {
      this.hideTarget("cooldownMessage")
      return
    }

    if (!this.lastHintRevealedAtValue) return

    const cooldownMs = this.cooldownMinutesValue * 60 * 1000
    const remainingMs = cooldownMs - (Date.now() - this.lastHintRevealedAtValue)

    if (remainingMs > 0) {
      this.disableHintButton()
      this.showTarget("cooldownMessage")
      this.updateCooldownTimer(remainingMs)
    } else {
      this.enableHintButton()
      this.hideTarget("cooldownMessage")
      this.clearCooldownInterval()
    }
  }

  updateCooldownTimer(remainingMs) {
    if (!this.hasCooldownTimerTarget) return

    const hours = Math.floor(remainingMs / 3600000)
    const minutes = Math.floor((remainingMs % 3600000) / 60000)
    const seconds = Math.floor((remainingMs % 60000) / 1000)

    if (hours > 0) {
      this.cooldownTimerTarget.textContent = `${hours}h ${minutes}m ${seconds}s`
    } else if (minutes > 0) {
      this.cooldownTimerTarget.textContent = `${minutes}m ${seconds}s`
    } else {
      this.cooldownTimerTarget.textContent = `${seconds}s`
    }
  }

  checkAndDisableHintButton() {
    if (!this.hasRevealHintBtnTarget) return
    if (!this.allHintsValue || !this.revealedHintsValue) return

    if (this.revealedHintsValue.length >= this.allHintsValue.length) {
      this.revealHintBtnTarget.disabled = true
      this.revealHintBtnTarget.textContent = "All Hints Revealed"
      this.revealHintBtnTarget.classList.add("bg-gray-400", "cursor-not-allowed")
      this.revealHintBtnTarget.classList.remove("bg-ruby-600", "hover:bg-ruby-700", "cursor-pointer")
      this.hideTarget("cooldownMessage")
      this.clearCooldownInterval()
    } else {
      this.checkCooldown()
    }
  }

  // --- Location Check ---

  checkLocation() {
    const now = Date.now()
    if (this.isCheckingLocation) return
    if (now - this.lastCheckTime < this.MIN_CHECK_INTERVAL) {
      const remaining = Math.ceil((this.MIN_CHECK_INTERVAL - (now - this.lastCheckTime)) / 1000)
      this.showLocationStatus(`Please wait ${remaining} second${remaining !== 1 ? "s" : ""} before checking again.`, "warning")
      return
    }

    this.isCheckingLocation = true
    this.lastCheckTime = now
    this.setCheckLocationButton(true, "Checking...")
    this.hideTarget("locationStatus")

    if (!navigator.geolocation) {
      this.isCheckingLocation = false
      this.setCheckLocationButton(false)
      this.showLocationStatus("Geolocation is not supported by your browser.", "error")
      return
    }

    this.tryGetLocation(true)
  }

  tryGetLocation(useHighAccuracy) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.isCheckingLocation = false
        this.setCheckLocationButton(false)

        this.postJSON(`/adventures/${this.adventureIdValue}/check_location`, {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy
        })
          .then(data => this.handleLocationResponse(data))
          .catch(() => this.showLocationStatus("Error checking location. Please try again.", "error"))
      },
      (error) => {
        if (error.code === error.TIMEOUT && useHighAccuracy) {
          this.showLocationStatus("High accuracy GPS timed out. Trying with standard accuracy...", "warning")
          this.tryGetLocation(false)
          return
        }

        this.isCheckingLocation = false
        this.setCheckLocationButton(false)
        this.handleGeolocationError(error)
      },
      {
        enableHighAccuracy: useHighAccuracy,
        timeout: useHighAccuracy ? 15000 : 30000,
        maximumAge: useHighAccuracy ? 0 : 60000
      }
    )
  }

  handleLocationResponse(data) {
    if (data.error) {
      this.showLocationStatus(`Error: ${data.error}`, "error")
      return
    }

    // Debug info for admins
    if (data.user_location && data.clue_location && this.hasDebugInfoTarget && this.hasDebugContentTarget) {
      this.debugContentTarget.innerHTML = `
        <div><strong>Your Location:</strong> ${data.user_location.lat.toFixed(6)}, ${data.user_location.long.toFixed(6)}</div>
        <div><strong>Clue Location:</strong> ${data.clue_location.lat.toFixed(6)}, ${data.clue_location.long.toFixed(6)}</div>
        <div><strong>Distance:</strong> ${data.distance} meters</div>
        ${data.user_accuracy ? `<div><strong>GPS Accuracy:</strong> ±${data.user_accuracy.toFixed(2)} meters</div>` : ""}
        <div><strong>Unlock Radius:</strong> ${data.unlock_radius} meters</div>
      `
      this.showTarget("debugInfo")
    }

    this.canClaim = data.can_claim || false
    this.claimToken = data.claim_token || null

    // Show/hide claim section
    if (this.canClaim && this.claimToken) {
      this.showTarget("claimSection")
    } else {
      this.hideTarget("claimSection")
    }

    // Show temperature message
    const message = this.canClaim
      ? (data.temperature?.message || "You're close enough to claim this clue!")
      : (data.temperature?.message || "You're not close enough yet. Keep searching!")

    const level = data.temperature?.level || (this.canClaim ? "hot" : "cold")
    this.showLocationStatus(message, this.temperatureLevelToType(level))
  }

  handleGeolocationError(error) {
    const messages = {
      [error.PERMISSION_DENIED]: {
        title: "Location Permission Denied",
        body: "You denied the request for geolocation.",
        tips: [
          "Enable Location Services/GPS on your device",
          "Move to an area with better GPS signal (outdoors, near a window)",
          "Enable Wi-Fi and cellular network location",
          "On mobile: Check Settings → Privacy → Location Services"
        ]
      },
      [error.POSITION_UNAVAILABLE]: {
        title: "Location Unavailable",
        body: "Location information is unavailable.",
        tips: [
          "Enable Location Services/GPS on your device",
          "Move to an area with better GPS signal",
          "Enable Wi-Fi and cellular network location"
        ]
      },
      [error.TIMEOUT]: {
        title: "Location Request Timed Out",
        body: "The location request took too long.",
        tips: [
          "Move to an open area with a clear view of the sky",
          "Wait a few seconds and try again",
          "Ensure Wi-Fi or cellular data is enabled"
        ]
      }
    }

    const info = messages[error.code] || {
      title: "Unknown Location Error",
      body: "An unexpected error occurred while trying to get your location.",
      tips: ["Refresh the page", "Check your browser and device location settings"]
    }

    if (this.hasLocationStatusTarget) {
      this.locationStatusTarget.innerHTML = `
        <div class="p-4 bg-red-50 border border-red-200 rounded-lg">
          <p class="font-semibold text-red-800 mb-2">${info.title}</p>
          <p class="text-red-700 text-sm mb-2">${info.body}</p>
          <ul class="text-red-700 text-sm list-disc pl-5 space-y-1">
            ${info.tips.map(tip => `<li>${tip}</li>`).join("")}
          </ul>
        </div>
      `
      this.locationStatusTarget.classList.remove("hidden")
    }
  }

  // --- Claim System ---

  claimClue() {
    if (!this.hasClaimBtnTarget) return

    if (!this.claimToken) {
      this.showLocationStatus("No valid claim token. Please check your location again.", "error")
      return
    }

    this.claimBtnTarget.disabled = true
    this.claimBtnTarget.textContent = "Claiming..."

    this.postJSON(`/adventures/${this.adventureIdValue}/claim_clue`, { claim_token: this.claimToken })
      .then(data => {
        if (data.error) {
          this.showLocationStatus(`Error: ${data.error}`, "error")
          this.claimBtnTarget.disabled = false
          this.claimBtnTarget.textContent = "Claim the Clue"
          return
        }
        window.location.reload()
      })
      .catch(() => {
        this.claimBtnTarget.disabled = false
        this.claimBtnTarget.textContent = "Claim the Clue"
        this.showLocationStatus("Error claiming clue. Please try again.", "error")
      })
  }

  forceClaim() {
    if (this.hasForceClaimModalTarget) {
      this.forceClaimModalTarget.classList.remove("hidden")
    }
  }

  forceClaimCancel() {
    if (this.hasForceClaimModalTarget) {
      this.forceClaimModalTarget.classList.add("hidden")
    }
  }

  forceClaimConfirm() {
    if (this.hasForceClaimModalTarget) {
      this.forceClaimModalTarget.classList.add("hidden")
    }

    const btn = document.getElementById("force-claim-btn")
    if (!btn) return

    btn.disabled = true
    btn.textContent = "Force Claiming..."

    this.postJSON(`/adventures/${this.adventureIdValue}/force_claim`)
      .then(data => {
        if (data.error) {
          this.showLocationStatus(`Error: ${data.error}`, "error")
          btn.disabled = false
          btn.textContent = "Force Claim"
          return
        }
        window.location.reload()
      })
      .catch(error => {
        btn.disabled = false
        btn.textContent = "Force Claim"
        this.showLocationStatus(`Error force claiming clue: ${error.message}`, "error")
      })
  }

  // --- Abandon Modal ---

  showAbandonModal() {
    if (this.hasAbandonModalTarget) {
      this.abandonModalTarget.classList.remove("hidden")
    }
  }

  hideAbandonModal() {
    if (this.hasAbandonModalTarget) {
      this.abandonModalTarget.classList.add("hidden")
    }
  }

  // --- Helpers ---

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }

  postJSON(url, body = null) {
    const options = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      }
    }
    if (body) options.body = JSON.stringify(body)
    return fetch(url, options).then(r => r.json())
  }

  showTarget(name) {
    const target = this[`${name}Target`]
    if (target) target.classList.remove("hidden")
  }

  hideTarget(name) {
    const hasMethod = `has${name.charAt(0).toUpperCase() + name.slice(1)}Target`
    if (this[hasMethod]) this[`${name}Target`].classList.add("hidden")
  }

  showLocationStatus(message, type = "info") {
    if (!this.hasLocationStatusTarget) return

    const styles = {
      error: "bg-red-50 border-red-200 text-red-800",
      warning: "bg-yellow-50 border-yellow-200 text-yellow-800",
      success: "bg-green-50 border-green-200 text-green-800",
      info: "bg-ruby-50 border-ruby-200 text-ruby-800",
      warm: "bg-orange-50 border-orange-200 text-orange-800",
      cold: "bg-blue-50 border-blue-200 text-blue-800"
    }

    this.locationStatusTarget.innerHTML = `
      <div class="p-4 border rounded-lg ${styles[type] || styles.info}">
        <p class="font-semibold text-sm">${message}</p>
      </div>
    `
    this.locationStatusTarget.classList.remove("hidden")
  }

  temperatureLevelToType(level) {
    return { hot: "success", warm: "warm", closer: "warning", cold: "cold" }[level] || "info"
  }

  resetHintButton() {
    if (this.hasRevealHintBtnTarget) {
      this.revealHintBtnTarget.disabled = false
      this.revealHintBtnTarget.textContent = "Reveal Hint"
    }
  }

  disableHintButton() {
    if (this.hasRevealHintBtnTarget) {
      this.revealHintBtnTarget.disabled = true
      this.revealHintBtnTarget.classList.add("bg-gray-400", "cursor-not-allowed")
      this.revealHintBtnTarget.classList.remove("bg-ruby-600", "hover:bg-ruby-700", "cursor-pointer")
    }
  }

  enableHintButton() {
    if (this.hasRevealHintBtnTarget) {
      this.revealHintBtnTarget.disabled = false
      this.revealHintBtnTarget.classList.remove("bg-gray-400", "cursor-not-allowed")
      this.revealHintBtnTarget.classList.add("bg-ruby-600", "hover:bg-ruby-700", "cursor-pointer")
    }
  }

  setCheckLocationButton(loading, text = "Check if I'm Close") {
    if (this.hasCheckLocationBtnTarget) {
      this.checkLocationBtnTarget.disabled = loading
      this.checkLocationBtnTarget.textContent = text
    }
  }

  startCooldownInterval(nextHintAvailableAt = null) {
    this.clearCooldownInterval()
    this.cooldownInterval = setInterval(() => {
      if (nextHintAvailableAt) {
        const remaining = new Date(nextHintAvailableAt).getTime() - Date.now()
        if (remaining > 0) {
          this.updateCooldownTimer(remaining)
          this.checkCooldown()
        } else {
          this.clearCooldownInterval()
          this.checkCooldown()
        }
      } else {
        this.checkCooldown()
      }
    }, 1000)
  }

  clearCooldownInterval() {
    if (this.cooldownInterval) {
      clearInterval(this.cooldownInterval)
      this.cooldownInterval = null
    }
  }
}
