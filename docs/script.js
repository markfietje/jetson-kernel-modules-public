// Copy to clipboard functionality
function copyToClipboard(button) {
  const codeBlock = button.parentElement;
  const code = codeBlock.querySelector("code");
  const text = code.textContent;

  navigator.clipboard
    .writeText(text)
    .then(() => {
      const originalHTML = button.innerHTML;
      button.innerHTML = '<i class="fas fa-check"></i>';
      button.style.background = "#28a745";

      setTimeout(() => {
        button.innerHTML = originalHTML;
        button.style.background = "#667eea";
      }, 2000);
    })
    .catch((err) => {
      console.error("Failed to copy text: ", err);
    });
}

// Tab functionality
function showTab(tabName) {
  // Hide all tabs
  const tabPanes = document.querySelectorAll(".tab-pane");
  tabPanes.forEach((pane) => {
    pane.classList.remove("active");
  });

  // Remove active class from all buttons
  const tabButtons = document.querySelectorAll(".tab-btn");
  tabButtons.forEach((btn) => {
    btn.classList.remove("active");
  });

  // Show selected tab
  document.getElementById(tabName).classList.add("active");

  // Add active class to clicked button
  event.target.classList.add("active");
}

// Smooth scroll for navigation links
document.addEventListener("DOMContentLoaded", function () {
  // Add smooth scrolling to navigation links
  const navLinks = document.querySelectorAll(".nav-links a");
  navLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      const href = this.getAttribute("href");
      if (href.startsWith("#")) {
        e.preventDefault();
        const target = document.querySelector(href);
        if (target) {
          target.scrollIntoView({
            behavior: "smooth",
            block: "start",
          });
        }
      }
    });
  });

  // Add scroll effect to navigation
  window.addEventListener("scroll", function () {
    const navbar = document.querySelector(".navbar");
    if (window.scrollY > 100) {
      navbar.style.background = "rgba(255, 255, 255, 0.98)";
    } else {
      navbar.style.background = "rgba(255, 255, 255, 0.95)";
    }
  });

  // Add animation classes when elements come into view
  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -50px 0px",
  };

  const observer = new IntersectionObserver(function (entries) {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("fade-in");
      }
    });
  }, observerOptions);

  // Observe feature cards, module cards, and other elements
  const animatedElements = document.querySelectorAll(
    ".feature-card, .module-card, .step, .compat-card",
  );
  animatedElements.forEach((el) => {
    observer.observe(el);
  });
});

// Add keyboard navigation for tabs
document.addEventListener("keydown", function (e) {
  if (e.key === "ArrowLeft" || e.key === "ArrowRight") {
    const activeTab = document.querySelector(".tab-btn.active");
    const tabButtons = Array.from(document.querySelectorAll(".tab-btn"));
    const currentIndex = tabButtons.indexOf(activeTab);

    let newIndex;
    if (e.key === "ArrowLeft") {
      newIndex = currentIndex > 0 ? currentIndex - 1 : tabButtons.length - 1;
    } else {
      newIndex = currentIndex < tabButtons.length - 1 ? currentIndex + 1 : 0;
    }

    tabButtons[newIndex].click();
  }
});

// Add search functionality (if needed in the future)
function addSearchFunctionality() {
  // Placeholder for future search implementation
  console.log("Search functionality can be added here");
}

// Performance monitoring
function trackPagePerformance() {
  // Track page load performance
  window.addEventListener("load", function () {
    const loadTime = performance.now();
    console.log(`Page loaded in ${loadTime.toFixed(2)}ms`);
  });
}

// Initialize everything when DOM is loaded
document.addEventListener("DOMContentLoaded", function () {
  trackPagePerformance();

  // Add loading animation removal
  document.body.style.opacity = "0";
  setTimeout(() => {
    document.body.style.transition = "opacity 0.5s ease";
    document.body.style.opacity = "1";
  }, 100);
});

// Error handling for broken images or links
document.addEventListener(
  "error",
  function (e) {
    if (e.target.tagName === "IMG") {
      e.target.style.display = "none";
      console.error("Image failed to load:", e.target.src);
    }
  },
  true,
);
