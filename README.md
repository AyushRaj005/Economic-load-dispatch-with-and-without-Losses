## Overview

This repository contains MATLAB implementations for solving the Economic Load Dispatch (ELD) problem under two scenarios:

1. **Neglecting transmission losses** with generator operating limits.
2. **Considering transmission losses** using **B-coefficients**, along with generator operating limits.

Both implementations use the **incremental fuel cost (λ-iteration)** approach with a user-defined convergence tolerance.

---

## Project A — ELD without Transmission Losses

### Objective {#objective-a}

Solve the ELD problem **considering generator limits** and **neglecting transmission losses** using MATLAB.

### Apparatus / System Specification {#system-specs-a}

* MATLAB R20xx (any version supporting basic matrix ops)
* CPU: <Give System specification>
* RAM: <Give System specification>
* OS: Windows/Linux/macOS

### Theory {#theory-a}

In classical ELD (neglecting losses), economic operation is achieved when **incremental costs** of all online generators are equal (subject to limits).
If each generator has a quadratic cost:

$$
F_i(P_i) = \alpha_i + \beta_i P_i + \gamma_i P_i^2
$$

then the condition for optimality (ignoring limits) is:

$$
\text{IC}_1 = \text{IC}_2 = \cdots = \text{IC}_N = \lambda,\quad\text{where } \text{IC}_i=\frac{dF_i}{dP_i}=\beta_i+2\gamma_i P_i
$$

### Mathematical Formulation {#math-formulation-a}

**Minimize**

$$
F_t=\sum_{i=1}^{N} F_i(P_i)
$$

**Subject to**

$$
\sum_{i=1}^{N} P_i = P_D,\quad P_{i,\min}\le P_i \le P_{i,\max}
$$

**Optimality (no losses):**

$$
\beta_i + 2\gamma_i P_i = \lambda \quad \Rightarrow\quad P_i=\frac{\lambda-\beta_i}{2\gamma_i}
$$

with limit handling (clamping to $P_{i,\min}$ or $P_{i,\max}$ when necessary).

### Algorithm (λ-Iteration) {#algorithm-a}

1. Read $P_{i,\min}, P_{i,\max}, \alpha_i,\beta_i,\gamma_i$, and demand $P_D$.
2. Choose initial $\lambda$ and step $\Delta\lambda$ (e.g., 0.01).
3. Set convergence tolerance $\varepsilon$.
4. Compute $P_i = \frac{\lambda-\beta_i}{2\gamma_i}$.
5. Enforce limits $P_{i,\min}\le P_i \le P_{i,\max}$.
6. Compute $\Delta P = \sum_i P_i - P_D$.
7. If $|\Delta P|<\varepsilon$: **stop**; else adjust $\lambda \leftarrow \lambda - \text{sign}(\Delta P)\cdot \Delta\lambda$ and repeat from Step 4.

### System Information {#system-information-a}

**Demand:** $P_D = 800\ \text{MW}$

| Gen | $P_{\min}$ (MW) | $P_{\max}$ (MW) | $\alpha$ | $\beta$ | $\gamma$ |
| --- | --------------: | --------------: | -------: | ------: | -------: |
| G1  |             150 |             600 |      510 |    7.20 |  0.00142 |
| G2  |             100 |             400 |      310 |    7.85 |  0.00194 |
| G3  |              50 |             200 |       18 |    7.97 |  0.00482 |

> *If your original lab sheet lists slightly different limits, keep those; the code will accept any table.*

## Project B — ELD with Transmission Losses (B-Coefficients)

### Objective {#objective-b}

Solve the ELD problem **considering transmission losses** (B-coefficients) and **generator limits** using MATLAB.

### Apparatus / System Specification {#system-specs-b}

* MATLAB R20xx 
* CPU/RAM/OS 

### Theory {#theory-b}

With network losses, economic operation satisfies the **equal incremental cost times penalty factor** rule:

$$
\text{IC}_i \cdot \text{PF}_i = \lambda \quad\text{for all online } i
$$

where $\text{IC}_i=\beta_i+2\gamma_i P_i$, and $\text{PF}_i$ depends on the loss sensitivity. Using B-coefficients, total real power loss is:

$$
P_L = \sum_{i=1}^N\sum_{j=1}^N B_{ij}P_iP_j + \sum_{i=1}^N B_{0i}P_i + B_{00}
$$

The power balance becomes:

$$
\sum_{i=1}^{N} P_i = P_D + P_L
$$

### Mathematical Formulation {#math-formulation-b}

**Minimize**

$$
F_t=\sum_{i=1}^{N} F_i(P_i)
$$

**Subject to**

$$
\sum_{i=1}^{N} P_i = P_D + P_L,\quad P_{i,\min}\le P_i \le P_{i,\max}
$$

**Key stationarity (used in iterative update / λ-iteration):**

$$
P_i \approx \frac{\lambda - \beta_i}{2(\gamma_i + \lambda B_{ii})}
$$

(then refine with updated $P_L$ each iteration; enforce limits each step).

### Algorithm (λ-Iteration with Losses) {#algorithm-b}

1. Read $P_{i,\min}, P_{i,\max}, \alpha_i,\beta_i,\gamma_i$, demand $P_D$, and B-coefficients $B_{ij}, B_{0i}, B_{00}$.
2. Choose initial $\lambda$ and $\Delta\lambda$ (e.g., 0.01).
3. Set convergence tolerance $\varepsilon$.
4. Compute provisional $P_i = \dfrac{\lambda-\beta_i}{2(\gamma_i + \lambda B_{ii})}$.
5. Enforce limits $P_{i,\min}\le P_i \le P_{i,\max}$.
6. Compute loss $P_L=\sum_i\sum_j B_{ij}P_iP_j + \sum_i B_{0i}P_i + B_{00}$.
7. Compute mismatch $\Delta P = \sum_i P_i - (P_D + P_L)$.
8. If $|\Delta P|<\varepsilon$: **stop**; else adjust $\lambda \leftarrow \lambda - \text{sign}(\Delta P)\cdot \Delta\lambda$ and repeat from Step 4.

> Alternative Newton-like update (if you want faster convergence):

$$
\Delta\lambda \approx \frac{\Delta P}{\sum_i \frac{1}{2(\gamma_i+\lambda B_{ii})}}
$$

### System Information {#system-information-b}

**Demand:** $P_D = 800\ \text{MW}$

**Generator Data**

| Gen | $P_{\min}$ (MW) | $P_{\max}$ (MW) | $\alpha$ | $\beta$ | $\gamma$ |
| --- | --------------: | --------------: | -------: | ------: | -------: |
| G1  |             150 |             500 |      510 |    7.20 |  0.00142 |
| G2  |             100 |             200 |      310 |    7.85 |  0.00194 |
| G3  |              50 |             200 |       18 |    7.97 |  0.00482 |

**Loss Coefficient Data**

$$
B = \begin{bmatrix}
0.000218 & 0.000093 & 0.000028\\
0.000093 & 0.000228 & 0.000017\\
0.000028 & 0.000031 & 0.000015
\end{bmatrix},\quad
\mathbf{B_0} = \begin{bmatrix} 0.0003 & 0.0031 & 0.0015 \end{bmatrix},\quad
B_{00}=0.00030523
$$

### Important Equations {#important-equations-b}

$$
\begin{aligned}
&F_i = \alpha_i + \beta_i P_i + \gamma_i P_i^2 \quad\text{for } i=1,\dots,N \\
&F_t = \sum_{i=1}^{N} F_i \\
&P_L = \sum_{i=1}^N\sum_{j=1}^N B_{ij}P_iP_j + \sum_{i=1}^N B_{0i}P_i + B_{00} \\
&\text{Balance: } \sum_{i=1}^{N} P_i = P_D + P_L \\
&\text{Limits: } P_{i,\min}\le P_i \le P_{i,\max} \\
&\text{No-loss opt.: } \beta_i + 2\gamma_i P_i = \lambda \\
&\text{With-loss heuristic: } P_i=\dfrac{\lambda-\beta_i}{2(\gamma_i + \lambda B_{ii})}
\end{aligned}
$$

> **Experiment 8 (same data as above)**
> $P_D = 800\ \text{MW}$ and the same generator tables and B-coefficients.


## Notes

* Start with a moderate $\Delta\lambda$ (e.g., 0.01). If convergence stalls, reduce it progressively or switch to the Newton-like $\Delta\lambda$ update shown above.
* Always enforce generator limits *every* iteration before computing mismatches/losses.
* Cost is computed as $F_t=\sum_i (\alpha_i + \beta_i P_i + \gamma_i P_i^2)$.

---
