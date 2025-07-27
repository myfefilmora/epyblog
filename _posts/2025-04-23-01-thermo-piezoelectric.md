---
layout: post
# author: "Epy Blog"
title: "Thermo-Piezoelectric FEM: From Deriving Full Governing Equations to Matrix Formulation"
tags:
  - PiezoElectrics
usemathjax:     true
more_updates_card: true
excerpt_separator: <!--more-->
---

Piezoelectric materials are already powerful due to their ability to couple mechanical and electrical fields — but when we add **temperature** into the mix, <!--more-->we unlock a new class of materials: **thermo-piezoelectric systems**. These systems are at the heart of smart sensors, actuators, and energy harvesting technologies, especially in thermally sensitive or high-temperature environments.

In this post, we derive the **complete governing equations** for thermo-piezoelectric solids by treating **displacement**, **voltage**, and **temperature** as full-fledged, coupled **field variables**. This sets the foundation for building multiphysics FEM solvers, PINNs, or hybrid approaches.

<div class="alert" role="alert" style="background-color: #fff3cd; border-left: 6px solid #ffeeba; padding: 1rem; font-size: 1rem; text-align:justify;">
  <strong>Disclaimer:</strong> While this post provides a complete first-principles derivation of the governing equations, boundary conditions, and FEM matrix formulation, certain implementation-level details (such as Jacobian mapping, numerical integration, and data structures) are intentionally abstracted.
  <br><br>
  As a result, this post is <strong>not intended as a direct coding guide</strong>, but rather as a conceptual and intuitive resource to help readers <strong>understand the mathematical structure</strong> of coupled field FEM for thermo-piezoelectric systems. Some gaps may remain from theory to code — and that’s okay. This post is meant to build the foundation.
</div>



## 1. Field Variables

Let $\Omega \subset \mathbb{R}^3$ be a solid domain. We define the primary fields of interest:

- **Displacement** $\mathbf{u}(x) = [u_1, u_2, u_3]^T$: describes how the solid deforms spatially
- **Voltage** $V(x)$: describes the electric potential field inside the material
- **Temperature** $T(x)$: describes the thermal distribution across the solid

We assume all fields are static and smooth enough for differentiation.



## 2. Derived Fields

From the primary fields, we define the quantities that appear in the constitutive equations:

### (a) Strain tensor:

The linear strain tensor (symmetric gradient of displacement):

$$
\varepsilon_{ij} = \frac{1}{2} \left( \frac{\partial u_i}{\partial x_j} + \frac{\partial u_j}{\partial x_i} \right)
$$

This measures how much the material is stretched or compressed.



### (b) Electric field:

The electric field vector is the **negative gradient of voltage**:

$$
E_i = -\frac{\partial V}{\partial x_i}
$$

This describes how voltage changes in space and gives rise to internal electrical forces.



### (c) Temperature gradient:

Defined as the spatial derivative of the temperature field:

$$
\theta_i = \frac{\partial T}{\partial x_i}
$$

This gradient drives **heat conduction** across the material.



## 3. Constitutive Laws (3-Way Coupling)

We now define how the **stress**, **electric displacement**, and **heat flux** are influenced by the three field variables.



### (a) Stress–strain–voltage–temperature relation:

The stress is influenced by:
- Elastic deformation (via strain)
- Piezoelectric effect (via electric field)
- Thermal expansion (via temperature change)

$$
\sigma_{ij} = C_{ijkl} \varepsilon_{kl} + e_{kij} \frac{\partial V}{\partial x_k} - \alpha_{ij} (T - T_0)
$$

Where:
- $C_{ijkl}$: elasticity tensor  
- $e_{kij}$: piezoelectric coupling tensor  
- $\alpha_{ij}$: thermal expansion tensor  
- $T_0$: reference temperature (often ambient)

Each term contributes to internal stresses:
- The first term is **mechanical stiffness**
- The second term is the **inverse piezoelectric effect**
- The third term is **thermal stress**



### (b) Electric displacement–strain–voltage–temperature relation:

The electric displacement depends on:
- Mechanical strain (direct piezoelectric effect)
- Electric field (standard dielectric response)
- Temperature (pyroelectric effect)

$$
D_i = e_{ikl} \varepsilon_{kl} - \varepsilon^S_{ik} \frac{\partial V}{\partial x_k} + p_i (T - T_0)
$$

Where:
- $\varepsilon^S_{ik}$: permittivity tensor (under constant strain)
- $p_i$: pyroelectric tensor (describes how temperature changes induce polarization)



### (c) Heat flux–temperature gradient relation:

Fourier’s law of heat conduction:

$$
q_i = -k_{ij} \frac{\partial T}{\partial x_j}
$$

Where $k_{ij}$ is the thermal conductivity tensor. This tells us how temperature gradients drive heat flow.



## 4. Strong Form of Governing Equations

With the above constitutive relations, we now write down the **governing PDEs** for the coupled system.



### (a) Mechanical equilibrium (no body force):

Internal stresses must balance:

$$
\frac{\partial \sigma_{ij}}{\partial x_j} = 0
$$

Substitute $\sigma_{ij}$:

$$
\frac{\partial}{\partial x_j} \left( C_{ijkl} \varepsilon_{kl} + e_{kij} \frac{\partial V}{\partial x_k} - \alpha_{ij} (T - T_0) \right) = 0
$$

This equation shows that **voltage and temperature both induce internal stress**.



### (b) Electrical equilibrium (no free charges):

Charge conservation implies:

$$
\frac{\partial D_i}{\partial x_i} = 0
$$

Substitute $D_i$:

$$
\frac{\partial}{\partial x_i} \left( e_{ikl} \varepsilon_{kl} - \varepsilon^S_{ik} \frac{\partial V}{\partial x_k} + p_i (T - T_0) \right) = 0
$$

This equation couples the **mechanical strain** and **temperature** into the electric field.



### (c) Thermal equilibrium (steady-state):

No internal heat sources, steady-state heat conduction:

$$
\frac{\partial q_i}{\partial x_i} = 0
\quad \Rightarrow \quad
\frac{\partial}{\partial x_i} \left( -k_{ij} \frac{\partial T}{\partial x_j} \right) = 0
$$

This equation evolves independently, but **temperature affects both stress and electric displacement** via the constitutive relations.

We’ve now completed the **full set of coupled PDEs** for the system, directly from first principles. These equations govern how deformation, voltage, and temperature interact inside a thermo-piezoelectric material.

In the next section, we’ll define the **boundary conditions** — for displacement, voltage, and temperature — and then derive the **weak forms** leading to the **finite element formulation**.

## 5. Boundary Conditions for Thermo-Piezoelectric Solids

To fully define the coupled PDE system, we need to impose **boundary conditions** on all three fields:

- Displacement field $\mathbf{u}$
- Voltage field $V$
- Temperature field $T$

Each field supports two types of boundary conditions:
- **Dirichlet (essential)**: where the field value is prescribed
- **Neumann (natural)**: where the flux or force associated with the field is prescribed

We denote the boundary of the domain by $\Gamma = \partial \Omega$, and decompose it into appropriate subsets for each condition.



### 5.1 Displacement Boundary Conditions (Mechanical)

The mechanical field $\mathbf{u}$ supports:

- **Dirichlet BC (Prescribed displacement):**
  
  $$
  \mathbf{u} = \bar{\mathbf{u}} \quad \text{on } \Gamma_u
  $$

  This means we are fixing the value of displacement (e.g., clamped or pinned ends).

- **Neumann BC (Prescribed traction):**

  $$
  \boldsymbol{\sigma} \cdot \mathbf{n} = \bar{\mathbf{t}} \quad \text{on } \Gamma_t
  $$

  This models applied forces or surface pressure. $\mathbf{n}$ is the outward unit normal, and $\bar{\mathbf{t}}$ is the traction vector.



### 5.2 Voltage Boundary Conditions (Electrical)

The electric potential field $V$ supports:

- **Dirichlet BC (Prescribed voltage):**

  $$
  V = \bar{V} \quad \text{on } \Gamma_V
  $$

  This is used when you apply a known potential (voltage) on electrodes or surfaces.

- **Neumann BC (Prescribed surface charge or electric flux):**

  $$
  \mathbf{D} \cdot \mathbf{n} = \bar{q} \quad \text{on } \Gamma_q
  $$

  This models a surface charge density or normal component of electric displacement.



### 5.3 Temperature Boundary Conditions (Thermal)

The temperature field $T$ supports:

- **Dirichlet BC (Prescribed temperature):**

  $$
  T = \bar{T} \quad \text{on } \Gamma_T
  $$

  This is used to simulate heating, cooling, or fixed thermal environments.

- **Neumann BC (Prescribed heat flux):**

  $$
  \mathbf{q} \cdot \mathbf{n} = \bar{h} \quad \text{on } \Gamma_h
  $$

  This represents an external heat input/output — e.g., heating pads, insulation, or convective boundaries.



### ✅ Summary of Boundary Condition Types

| Field         | Dirichlet (Essential)                 | Neumann (Natural)                         |
|:---------------|:----------------------------------------|:--------------------------------------------|
| Displacement  | $\mathbf{u} = \bar{\mathbf{u}}$ on $\Gamma_u$ | $\boldsymbol{\sigma} \cdot \mathbf{n} = \bar{\mathbf{t}}$ on $\Gamma_t$ |
| Voltage       | $V = \bar{V}$ on $\Gamma_V$           | $\mathbf{D} \cdot \mathbf{n} = \bar{q}$ on $\Gamma_q$         |
| Temperature   | $T = \bar{T}$ on $\Gamma_T$           | $\mathbf{q} \cdot \mathbf{n} = \bar{h}$ on $\Gamma_h$         |

Each of these boundary conditions will play a role when we derive the **weak form** of the system, especially the **Neumann BCs**, which appear naturally as surface integrals.


In the next sections, we’ll derive the **weak form** of the coupled PDE system — and lay the foundation for the full **finite element matrix formulation** that handles displacement, voltage, and temperature in one unified framework.

## 6. Weak Form of the Thermo-Piezoelectric System

We now derive the **weak form** (variational form) of the governing PDEs from Part 1.

We multiply each PDE by its corresponding **test function**, integrate over the domain, and use **integration by parts** to shift derivatives from the field to the test function — this is the standard FEM process that enables numerical discretization.

We define:
- $\delta \mathbf{u}$ — virtual displacement
- $\delta V$ — virtual voltage
- $\delta T$ — virtual temperature

Let’s derive each weak form separately.



### 6.1 Weak Form: Mechanical Equation

Start with:

$$
\int_\Omega \delta u_i \, \frac{\partial \sigma_{ij}}{\partial x_j} \, d\Omega = 0
$$

Apply integration by parts:

$$
- \int_\Omega \frac{\partial \delta u_i}{\partial x_j} \, \sigma_{ij} \, d\Omega + \int_{\Gamma_t} \delta u_i \, \bar{t}_i \, d\Gamma = 0
$$

Now substitute the **coupled constitutive law** for $\sigma_{ij}$:

$$
\sigma_{ij} = C_{ijkl} \varepsilon_{kl} + e_{kij} \frac{\partial V}{\partial x_k} - \alpha_{ij}(T - T_0)
$$

Then the weak form becomes:

$$
\int_\Omega \frac{\partial \delta u_i}{\partial x_j} \left(
C_{ijkl} \varepsilon_{kl} + e_{kij} \frac{\partial V}{\partial x_k} - \alpha_{ij}(T - T_0)
\right) d\Omega
= \int_{\Gamma_t} \delta u_i \, \bar{t}_i \, d\Gamma
$$

This will lead to 3 terms:
- **Elastic stiffness**
- **Electromechanical coupling**
- **Thermal stress coupling**



### 6.2 Weak Form: Electrical Equation

Start from:

$$
\int_\Omega \delta V \, \frac{\partial D_i}{\partial x_i} \, d\Omega = 0
$$

Apply integration by parts:

$$
- \int_\Omega \frac{\partial \delta V}{\partial x_i} \, D_i \, d\Omega + \int_{\Gamma_q} \delta V \, \bar{q} \, d\Gamma = 0
$$

Substitute $D_i$:

$$
D_i = e_{ikl} \varepsilon_{kl} - \varepsilon^S_{ik} \frac{\partial V}{\partial x_k} + p_i (T - T_0)
$$

Then the weak form becomes:

$$
\int_\Omega \frac{\partial \delta V}{\partial x_i}
\left(
e_{ikl} \varepsilon_{kl} - \varepsilon^S_{ik} \frac{\partial V}{\partial x_k} + p_i (T - T_0)
\right)
\, d\Omega
= \int_{\Gamma_q} \delta V \, \bar{q} \, d\Gamma
$$

This introduces:
- **Dielectric energy**
- **Piezoelectric coupling**
- **Pyroelectric source term**



### 6.3 Weak Form: Thermal Equation

Start with:

$$
\int_\Omega \delta T \, \frac{\partial}{\partial x_i} \left(-k_{ij} \frac{\partial T}{\partial x_j} \right) d\Omega = 0
$$

Apply integration by parts:

$$
\int_\Omega \frac{\partial \delta T}{\partial x_i} \, k_{ij} \frac{\partial T}{\partial x_j} \, d\Omega
= \int_{\Gamma_h} \delta T \, \bar{h} \, d\Gamma
$$

This is the standard **steady-state heat conduction** weak form — no coupling appears here explicitly, but temperature influences other fields through constitutive laws.



## 7. FEM Interpolation and Element Matrices

We now approximate each field using shape functions $N_a(x)$ for node $a$.



### 7.1 Nodal Field Approximation

For an 8-noded solid element:

- Displacement:
  $$
  \mathbf{u}(x) = \sum_{a=1}^8 N_a(x) \cdot \mathbf{u}_a
  $$

- Voltage:
  $$
  V(x) = \sum_{a=1}^8 N_a(x) \cdot V_a
  $$

- Temperature:
  $$
  T(x) = \sum_{a=1}^8 N_a(x) \cdot T_a
  $$

Each node carries:
- 3 mechanical DOFs: $u_a$, $v_a$, $w_a$
- 1 electrical DOF: $V_a$
- 1 thermal DOF: $T_a$

Total: **5 DOFs per node** × 8 nodes = **40 DOFs per element**



### 7.2 B-Matrices for Field Gradients

We define the following matrices:

- **$\mathbf{B}_u$**: strain-displacement matrix (6×24)  
  Maps nodal displacements to $\varepsilon$

- **$\mathbf{B}_V$**: voltage gradient matrix (3×8)  
  Maps nodal voltages to electric field: $\mathbf{E} = -\mathbf{B}_V \mathbf{V}_e$

- **$\mathbf{B}_T$**: temperature gradient matrix (3×8)  
  Maps nodal temperatures to heat flux vector


We’ve now derived the **weak forms** of the thermo-piezoelectric PDE system and identified the field approximations and gradient matrices needed for FEM.

In the next section, we’ll assemble all the corresponding **element matrices** — stiffness, coupling, and loading — and present the final **40×40 global system** for a single element.

## 8. Assembling the Final FEM Matrices

Now that we have the weak forms and field interpolations, we are ready to derive the **element-level finite element matrices** for the coupled thermo-piezoelectric system.

Each 8-noded solid element carries:
- 3 displacement DOFs per node → $3 \times 8 = 24$
- 1 voltage DOF per node → $1 \times 8 = 8$
- 1 temperature DOF per node → $1 \times 8 = 8$

So the total number of DOFs per element is:

$$
24 \ (\text{mechanical}) + 8 \ (\text{electrical}) + 8 \ (\text{thermal}) = \boxed{40 \text{ DOFs}}
$$

We now define the contributions to each block of the final **40×40 element stiffness matrix**.



### 8.1 Mechanical Stiffness Matrix $\mathbf{K}_{uu}$

Pure mechanical term from strain energy:

$$
\boxed{
\mathbf{K}_{uu} = \int_{\Omega^e} \mathbf{B}_u^T \, \mathbf{C} \, \mathbf{B}_u \, d\Omega
}
$$

- Size: $24 \times 24$
- Standard FEM elasticity matrix
- Includes no coupling yet



### 8.2 Electromechanical Coupling Matrix $\mathbf{K}_{uV}$

Comes from the inverse piezoelectric effect (voltage → stress):

$$
\boxed{
\mathbf{K}_{uV} = \int_{\Omega^e} \mathbf{B}_u^T \, \mathbf{e}^T \, \mathbf{B}_V \, d\Omega
}
$$

Transpose appears in the electrical equation:

$$
\boxed{
\mathbf{K}_{Vu} = \mathbf{K}_{uV}^T
}
$$

- Size: $24 \times 8$ and $8 \times 24$
- Captures how voltage generates mechanical strain and vice versa



### 8.3 Thermoelastic Coupling Matrix $\mathbf{K}_{uT}$

Thermal strain (temperature → stress):

$$
\boxed{
\mathbf{K}_{uT} = - \int_{\Omega^e} \mathbf{B}_u^T \, \boldsymbol{\alpha} \, \mathbf{N}_T \, d\Omega
}
$$

- Size: $24 \times 8$
- Models how thermal expansion affects stress



### 8.4 Dielectric Matrix $\mathbf{K}_{VV}$

Electric energy storage (pure electrostatics):

$$
\boxed{
\mathbf{K}_{VV} = \int_{\Omega^e} \mathbf{B}_V^T \, \boldsymbol{\varepsilon}^S \, \mathbf{B}_V \, d\Omega
}
$$

- Size: $8 \times 8$



### 8.5 Pyroelectric Coupling Matrix $\mathbf{K}_{VT}$

How temperature influences electric displacement:

$$
\boxed{
\mathbf{K}_{VT} = \int_{\Omega^e} \mathbf{B}_V^T \, \mathbf{p} \, \mathbf{N}_T \, d\Omega
}
$$

- Size: $8 \times 8$
- Arises from temperature-induced polarization



### 8.6 Thermal Conductivity Matrix $\mathbf{K}_{TT}$

From steady-state heat conduction:

$$
\boxed{
\mathbf{K}_{TT} = \int_{\Omega^e} \mathbf{B}_T^T \, \mathbf{k} \, \mathbf{B}_T \, d\Omega
}
$$

- Size: $8 \times 8$



## 9. Final Coupled Element Matrix (40 × 40 Block Form)

All individual contributions are assembled into one unified block matrix:

$$
\begin{bmatrix}
\mathbf{K}_{uu} & \mathbf{K}_{uV} & \mathbf{K}_{uT} \\
\mathbf{K}_{Vu} & \mathbf{K}_{VV} & \mathbf{K}_{VT} \\
\mathbf{K}_{Tu} & \mathbf{K}_{TV} & \mathbf{K}_{TT}
\end{bmatrix}
\begin{Bmatrix}
\mathbf{u}_e \\
\mathbf{V}_e \\
\mathbf{T}_e
\end{Bmatrix}
=
\begin{Bmatrix}
\mathbf{f}_u \\
\mathbf{f}_V \\
\mathbf{f}_T
\end{Bmatrix}
$$

Where:
- $\mathbf{u}_e \in \mathbb{R}^{24}$: displacement vector
- $\mathbf{V}_e \in \mathbb{R}^{8}$: nodal voltages
- $\mathbf{T}_e \in \mathbb{R}^{8}$: nodal temperatures



### 🔍 Notes on Symmetry and Coupling
<ul>
  <li><span>$\mathbf{K}_{uV}$</span> and <span>$\mathbf{K}_{Vu}$</span> — are transposes</li>
  <li><span>$\mathbf{K}_{uT}$</span> — is typically non-symmetric (thermal expansion direction matters)</li>
  <li><span>$\mathbf{K}_{Tu}$</span> and <span>$\mathbf{K}_{TV}$</span> — are <strong>often zero</strong> in linear analysis, but can be added in nonlinear cases (e.g., temperature-dependent stiffness, Joule heating, etc.)</li>
</ul>




## 10. Load Vectors

Each field has its own external loading:

- $\mathbf{f}_u$: mechanical forces (from traction BCs)
- $\mathbf{f}_V$: applied charge density
- $\mathbf{f}_T$: surface or internal heat input

These are computed via:

$$
\mathbf{f}_u = \int_{\Gamma_t} \mathbf{N}_u^T \bar{\mathbf{t}} \, d\Gamma
$$

$$
\mathbf{f}_V = \int_{\Gamma_q} \mathbf{N}_V^T \bar{q} \, d\Gamma
$$

$$
\mathbf{f}_T = \int_{\Gamma_h} \mathbf{N}_T^T \bar{h} \, d\Gamma
$$


## Summary

We’ve now completed the full finite element formulation for a **3-field thermo-piezoelectric solid**:

- 3D displacement
- Electric potential
- Temperature

Each physical effect is captured in a clean matrix block, with **clear physical meaning** and **implementation-ready structure**.

You can now plug these expressions into an FEM solver or use them as the starting point for building a physics-informed neural network (PINN) model.

---

> **Note:** This post was built using domain knowledge and structured assistance from AI to ensure clarity and consistency. If you have corrections or suggestions, please let us know via our **members-only chat** — we value your input and aim to keep improving our content.

