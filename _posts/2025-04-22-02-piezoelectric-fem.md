---
layout: post
# author: "Epy Blog"
title: "Piezoelectric FEM: Deriving Element Matrices for an 8-Noded Solid Element"
tags:
  - PiezoElectrics
usemathjax:     true
more_updates_card: true
excerpt_separator: <!--more-->
---

Piezoelectric materials exhibit a two-way coupling between electrical and mechanical fields. When you apply voltage to them, they deform. When you apply mechanical stress, they generate electrical charge. <!--more-->This fascinating behavior is used in a wide range of applications like sensors, actuators, ultrasound devices, and energy harvesting systems.


In this post, we derive the **finite element formulation of linear piezoelectricity** using a **3D 8-noded solid element** (also called a hexahedral or brick element). Our goal is to arrive at the **element matrices** that fully describe the coupling between displacement and voltage degrees of freedom (DOFs), starting from the governing equations and building all terms from scratch.

<div class="alert" role="alert" style="background-color: #fff3cd; border-left: 6px solid #ffeeba; padding: 1rem; font-size: 1rem; text-align:justify;">
  <strong>Disclaimer:</strong> While this post provides a complete first-principles derivation of the governing equations, boundary conditions, and FEM matrix formulation, certain implementation-level details (such as Jacobian mapping, numerical integration, and data structures) are intentionally abstracted.
  <br><br>
  As a result, this post is <strong>not intended as a direct coding guide</strong>, but rather as a conceptual and intuitive resource to help readers <strong>understand the mathematical structure</strong> of coupled field FEM for thermo-piezoelectric systems. Some gaps may remain from theory to code — and that’s okay. This post is meant to build the foundation.
</div>


## 1. The Element and Its Degrees of Freedom

We consider a **3D hexahedral element with 8 nodes**.

### 🔹 DOFs per node:
- **3 displacement components**: $u$, $v$, $w$ (in x, y, z)
- **1 voltage**: $V$

So, each node has **4 DOFs**.

### 🔹 Total DOFs:
- $8$ nodes × $4$ DOFs = **32 DOFs per element**

We define the global nodal vector for this element as:


$$
\mathbf{d}_e =
\left[
\begin{array}{c}
\mathbf{u}_1 \\ 
V_1 \\
\mathbf{u}_2 \\ 
V_2 \\
\vdots \\
\mathbf{u}_8 \\ 
V_8
\end{array}
\right]
=
\left[
\begin{array}{c}
u_1 \\ v_1 \\ w_1 \\ V_1 \\
u_2 \\ v_2 \\ w_2 \\ V_2 \\
\vdots \\
u_8 \\ v_8 \\ w_8 \\ V_8
\end{array}
\right]
\in \mathbb{R}^{32}
$$


$$
\mathbf{B}_V =
\begin{bmatrix}
\frac{\partial N_1}{\partial x} & \cdots & \frac{\partial N_8}{\partial x} \\
\frac{\partial N_1}{\partial y} & \cdots & \frac{\partial N_8}{\partial y} \\
\frac{\partial N_1}{\partial z} & \cdots & \frac{\partial N_8}{\partial z}
\end{bmatrix}
$$

This will be the primary unknown we solve for in our finite element system.



## 2. Governing Equations

The behavior of piezoelectric materials is governed by two main equations:

### (a) Mechanical equilibrium:

$$
\frac{\partial \sigma_{ij}}{\partial x_j} = 0
$$

This is the static version of Newton’s law — it ensures that internal stresses are in equilibrium.

### (b) Gauss’s Law (no free charge):

$$
\frac{\partial D_i}{\partial x_i} = 0
$$

This ensures the conservation of electric flux in the material under static conditions.



## 3. Constitutive Laws (Coupling Voltage and Strain)

Piezoelectric materials are **electromechanically coupled**, and this coupling appears in their constitutive laws.

### Electric field from voltage:

$$
E_k = -\frac{\partial V}{\partial x_k}
$$

### Strain from displacement:

$$
\varepsilon_{kl} = \frac{1}{2} \left( \frac{\partial u_k}{\partial x_l} + \frac{\partial u_l}{\partial x_k} \right)
$$

### Coupled constitutive laws:

- **Stress:**

  $$
  \sigma_{ij} = C_{ijkl} \varepsilon_{kl} + e_{kij} \frac{\partial V}{\partial x_k}
  $$

  This includes both elastic deformation and stress induced by voltage (inverse piezoelectric effect).

- **Electric displacement:**

  $$
  D_i = e_{ikl} \varepsilon_{kl} - \varepsilon^S_{ik} \frac{\partial V}{\partial x_k}
  $$

  This includes electric field effects and the electric charge induced by mechanical strain (direct piezoelectric effect).



## 4. Field Interpolation Using Shape Functions

> **Note:** While 8-noded hexahedral elements are typically defined using shape functions in the natural coordinate system $(\xi, \eta, \zeta)$, this derivation is carried out directly in the **global coordinate system** $(x, y, z)$ for conceptual clarity. As such, we assume that the shape function derivatives $\partial N_a/\partial x$, $\partial N_a/\partial y$, and $\partial N_a/\partial z$ are either directly available or computed after mapping through the Jacobian, though the Jacobian itself is not explicitly shown here. For intuition and ease of understanding, you may simply ignore this note during a first read.For conceptual understanding, you can simple ignore this note.

We define shape functions $N_a$ for node $a = 1$ to $8$.

### Displacement field:

$$
u(x) = \sum_{a=1}^{8} N_a(x) \cdot u_a, \quad v(x) = \sum_{a=1}^{8} N_a(x) \cdot v_a, \quad w(x) = \sum_{a=1}^{8} N_a(x) \cdot w_a
$$

### Voltage field:

$$
V(x) = \sum_{a=1}^{8} N_a(x) \cdot V_a
$$

This gives us continuous displacement and voltage fields across the element.



## 5. Strain-Displacement Matrix $\mathbf{B}_u$

To compute strain from nodal displacements, we use a matrix $\mathbf{B}_u$ such that:

$$
\boldsymbol{\varepsilon} = \mathbf{B}_u \cdot \mathbf{u}_e
$$

For 3D hexahedral elements, in Voigt notation:

$$
\boldsymbol{\varepsilon} =
\begin{bmatrix}
\varepsilon_{xx} \\
\varepsilon_{yy} \\
\varepsilon_{zz} \\
\varepsilon_{yz} \\
\varepsilon_{xz} \\
\varepsilon_{xy}
\end{bmatrix}
$$

The $\mathbf{B}_u$ matrix (6 × 24) uses derivatives of $N_a$ w.r.t $x$, $y$, $z$ for all 8 nodes.



## 6. Voltage Gradient Matrix $\mathbf{B}_V$

The electric field is the gradient of the voltage field. We define $\mathbf{B}_V$ such that:

$$
\mathbf{E} = - \mathbf{B}_V \cdot \mathbf{V}_e
$$

Where:

$$
\mathbf{B}_V =
\begin{bmatrix}
\frac{\partial N_1}{\partial x} & \cdots & \frac{\partial N_8}{\partial x} \\
\frac{\partial N_1}{\partial y} & \cdots & \frac{\partial N_8}{\partial y} \\
\frac{\partial N_1}{\partial z} & \cdots & \frac{\partial N_8}{\partial z}
\end{bmatrix}
$$



## 7. Element Matrix Formulation

We now build all the required submatrices of the 32×32 global matrix for the element.

### (a) Mechanical stiffness matrix (24 × 24):

$$
\mathbf{K}_{uu} = \int_{\Omega^e} \mathbf{B}_u^T \, \mathbf{C} \, \mathbf{B}_u \, d\Omega
$$

This handles pure elasticity.



### (b) Electromechanical coupling matrix (24 × 8):

$$
\mathbf{K}_{uV} = \int_{\Omega^e} \mathbf{B}_u^T \, \mathbf{e}^T \, \mathbf{B}_V \, d\Omega, \quad
\mathbf{K}_{Vu} = \mathbf{K}_{uV}^T
$$

These capture coupling between voltage and stress.



### (c) Dielectric matrix (8 × 8):

$$
\mathbf{K}_{VV} = \int_{\Omega^e} \mathbf{B}_V^T \, \boldsymbol{\varepsilon}^S \, \mathbf{B}_V \, d\Omega
$$

This models the pure electrostatic energy stored in the system.



## 8. Load Vectors

If mechanical traction or electric flux is applied on boundaries, they are represented as:

### (a) Mechanical force vector:

$$
\mathbf{f}_u = \int_{\Gamma_t} \mathbf{N}_u^T \bar{\mathbf{t}} \, d\Gamma
$$

### (b) Electrical charge vector:

$$
\mathbf{f}_V = \int_{\Gamma_q} \mathbf{N}_V^T \bar{q} \, d\Gamma
$$

These contribute to the right-hand side of the FEM system.



## 9. Final 32×32 Coupled System for the Element

Putting all pieces together, the full element equation is:

$$
\begin{bmatrix}
\mathbf{K}_{uu} & \mathbf{K}_{uV} \\
\mathbf{K}_{Vu} & \mathbf{K}_{VV}
\end{bmatrix}
\begin{Bmatrix}
\mathbf{u}_e \\
\mathbf{V}_e
\end{Bmatrix}
=
\begin{Bmatrix}
\mathbf{f}_u \\
\mathbf{f}_V
\end{Bmatrix}
$$

Where:
- $\mathbf{u}_e \in \mathbb{R}^{24}$ – mechanical DOFs  
- $\mathbf{V}_e \in \mathbb{R}^{8}$ – electrical DOFs  
- $\mathbf{K}_{uu} \in \mathbb{R}^{24 \times 24}$  
- $\mathbf{K}_{VV} \in \mathbb{R}^{8 \times 8}$  
- $\mathbf{K}_{uV} \in \mathbb{R}^{24 \times 8}$



## 10. Summary

In this post, we derived the complete **finite element formulation for a 3D 8-noded piezoelectric solid element**, clearly showing how displacement and voltage fields are interpolated and coupled.

This 32×32 system fully captures the electromechanical behavior of the material and serves as the core for simulating sensors, actuators, and other piezoelectric devices.

---

> **Note:** This post was developed through domain expertise and structured AI assistance to ensure mathematical clarity and physical accuracy. If you spot any issues or have suggestions to improve it further, please reach out to us in our **members-only chat**. Your feedback helps refine and improve these educational resources for everyone.
