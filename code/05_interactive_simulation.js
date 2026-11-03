
/*
Blog Post 8 - Interactive Bootstrap Simulation

Uses:
- Normal population simulation
- Bootstrap percentile confidence intervals
- Plotly.js for interactive visualization

No server required.
*/

(function () {
  "use strict";

  // Reproducible pseudo-random number generator
  function makeRNG(seed) {
    let state = seed >>> 0;

    return function () {
      state = (1664525 * state + 1013904223) >>> 0;
      return (state + 0.5) / 4294967296;
    };
  }

  function normalRandom(rng) {
    const u1 = rng();
    const u2 = rng();

    return Math.sqrt(-2 * Math.log(u1)) *
      Math.cos(2 * Math.PI * u2);
  }

  function mean(values) {
    return values.reduce((a, b) => a + b, 0) /
      values.length;
  }

  function quantile(sorted, p) {
    const h = (sorted.length - 1) * p;
    const lo = Math.floor(h);
    const hi = Math.ceil(h);
    return sorted[lo] +
      (sorted[hi] - sorted[lo]) * (h - lo);
  }

  function runSimulation() {
    const n = Number(document.getElementById("sim-n").value);
    const B = Number(document.getElementById("sim-b").value);
    const mu = Number(document.getElementById("sim-mu").value);
    const level = Number(document.getElementById("sim-level").value);

    const sigma = 10;
    const rng = makeRNG(6408);

    // Generate one original sample
    const sample = Array.from(
      { length: n },
      () => mu + sigma * normalRandom(rng)
    );

    const sampleMean = mean(sample);

    // Bootstrap resampling
    const bootstrapMeans = [];

    for (let b = 0; b < B; b++) {
      let total = 0;

      for (let i = 0; i < n; i++) {
        const index = Math.floor(rng() * n);
        total += sample[index];
      }

      bootstrapMeans.push(total / n);
    }

    const sorted = [...bootstrapMeans].sort((a, b) => a - b);

    const alpha = 1 - level;

    const lower = quantile(sorted, alpha / 2);
    const upper = quantile(sorted, 1 - alpha / 2);

    const covered = lower <= mu && mu <= upper;

    // Update text
    document.getElementById("sim-results").textContent =
      `Sample mean: ${sampleMean.toFixed(2)} | ` +
      `${(level * 100).toFixed(0)}% CI: ` +
      `[${lower.toFixed(2)}, ${upper.toFixed(2)}] | ` +
      `Contains true mean: ${covered ? "Yes" : "No"}`;

    // Plot bootstrap distribution
    const traces = [
      {
        x: bootstrapMeans,
        type: "histogram",
        histnorm: "probability density",
        nbinsx: 35,
        marker: { color: "#5B8DB8" },
        name: "Bootstrap means"
      }
    ];

    const layout = {
      title: "Bootstrap Distribution of the Sample Mean",
      xaxis: { title: "Bootstrap Sample Mean" },
      yaxis: { title: "Density" },
      shapes: [
        {
          type: "line",
          x0: lower, x1: lower,
          y0: 0, y1: 1,
          yref: "paper",
          line: { color: "#E76F51", dash: "dash" }
        },
        {
          type: "line",
          x0: upper, x1: upper,
          y0: 0, y1: 1,
          yref: "paper",
          line: { color: "#E76F51", dash: "dash" }
        },
        {
          type: "line",
          x0: sampleMean, x1: sampleMean,
          y0: 0, y1: 1,
          yref: "paper",
          line: { color: "#264653", dash: "dot" }
        },
        {
          type: "line",
          x0: mu, x1: mu,
          y0: 0, y1: 1,
          yref: "paper",
          line: { color: "#2A9D8F", width: 2 }
        }
      ],
      margin: { t: 65, b: 65, l: 65, r: 25 },
      paper_bgcolor: "white",
      plot_bgcolor: "white"
    };

    Plotly.react("bootstrap-plot", traces, layout, {
      responsive: true,
      displaylogo: false
    });
  }

  function initialize() {
    const button = document.getElementById("run-simulation");

    if (!button || typeof Plotly === "undefined") {
      return;
    }

    button.addEventListener("click", runSimulation);

    runSimulation();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initialize);
  } else {
    initialize();
  }
})();
