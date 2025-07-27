---
layout: post
# author: "Epy Blog"
title: "Piezoelectric Coupling – Deriving the Full Governing Equations"
tags:
  - PiezoElectrics
usemathjax:     true
more_updates_card: true
excerpt_separator: <!--more-->
---

Piezoelectric materials are fascinating: they **generate electricity when squeezed** and **deform when subjected to electric fields**.
<!--more-->
This two-way coupling between **mechanical** and **electrical** fields makes them indispensable in devices like:

- Ultrasound transducers  
- MEMS sensors and actuators  
- Energy harvesters  
- Precision control systems  

In this post, we derive the **strongly coupled PDE system** that governs linear piezoelectricity — where **displacement and electric potential are fully interdependent**.

## Field Variables

We work with the following:

- **$\mathbf{u}$**: Displacement vector  
- **$\phi$**: Electric potential  
- **$\boldsymbol{\varepsilon}$**: Strain tensor  
- **$\boldsymbol{\sigma}$**: Cauchy stress tensor  
- **$\mathbf{E}$**: Electric field ($E_i = -\partial \phi / \partial x_i$)  
- **$\mathbf{D}$**: Electric displacement (flux density)

Material constants:

- **$\mathbf{C}$**: Elasticity (stiffness) tensor  
- **$\mathbf{e}$**: Piezoelectric tensor  
- **$\boldsymbol{\varepsilon}^S$**: Permittivity tensor (at constant strain)



## Strain–Displacement and Electric Field–Potential

### Strain tensor (small deformation assumption):

$$
\varepsilon_{ij} = \frac{1}{2} \left( \frac{\partial u_i}{\partial x_j} + \frac{\partial u_j}{\partial x_i} \right)
$$

### Electric field vector:

$$
E_i = -\frac{\partial \phi}{\partial x_i}
$$



## Coupled Constitutive Laws

### Stress–Strain–Electric Field:

$$
\sigma_{ij} = C_{ijkl} \varepsilon_{kl} - e_{kij} E_k
$$

### Electric Displacement–Strain–Electric Field:

$$
D_i = e_{ikl} \varepsilon_{kl} + \varepsilon^S_{ik} E_k
$$

This defines the **bidirectional electromechanical coupling**:
- Mechanical strain creates electric displacement  
- Electric field induces mechanical stress



## Governing PDEs

### Mechanical Equilibrium

No body forces or inertia assumed:

$$
\frac{\partial \sigma_{ij}}{\partial x_j} = 0
$$

Substitute stress:

$$
\frac{\partial}{\partial x_j} \left( C_{ijkl} \varepsilon_{kl} - e_{kij} E_k \right) = 0
$$



### Gauss’s Law for Dielectrics

No free charges:

$$
\frac{\partial D_i}{\partial x_i} = 0
$$

Substitute electric displacement:

$$
\frac{\partial}{\partial x_i} \left( e_{ikl} \varepsilon_{kl} + \varepsilon^S_{ik} E_k \right) = 0
$$



## Final Coupled PDE System

### Mechanical PDE:

$$
\frac{\partial}{\partial x_j} \left( C_{ijkl} \varepsilon_{kl} - e_{kij} \frac{\partial \phi}{\partial x_k} \right) = 0
$$

### Electrical PDE:

$$
\frac{\partial}{\partial x_i} \left( e_{ikl} \varepsilon_{kl} - \varepsilon^S_{ik} \frac{\partial \phi}{\partial x_k} \right) = 0
$$

With strain defined by:

$$
\varepsilon_{kl} = \frac{1}{2} \left( \frac{\partial u_k}{\partial x_l} + \frac{\partial u_l}{\partial x_k} \right)
$$



## Boundary Conditions

### Mechanical:

- **Dirichlet (Displacement):** $\mathbf{u} = \bar{\mathbf{u}}$  
- **Neumann (Traction):** $\boldsymbol{\sigma} \cdot \mathbf{n} = \bar{\mathbf{t}}$

### Electrical:

- **Dirichlet (Voltage):** $\phi = \bar{\phi}$  
- **Neumann (Charge Flux):** $\mathbf{D} \cdot \mathbf{n} = \bar{q}$

These conditions are applied on respective boundary segments depending on device geometry and loading.



## Practical Implementation: Voigt Notation

For numerical implementation, we typically rewrite these in **matrix (Voigt) form**:

- $\boldsymbol{\varepsilon} \in \mathbb{R}^6$  
- $\boldsymbol{\sigma} \in \mathbb{R}^6$  
- $\mathbf{E}, \mathbf{D} \in \mathbb{R}^3$

Then the constitutive relations become:

$$
\boldsymbol{\sigma} = \mathbf{C} \boldsymbol{\varepsilon} - \mathbf{e}^T \mathbf{E}
$$

$$
\mathbf{D} = \mathbf{e} \boldsymbol{\varepsilon} + \boldsymbol{\varepsilon}^S \mathbf{E}
$$

Where:
- $\mathbf{C}$ is the $6 \times 6$ stiffness matrix  
- $\mathbf{e}$ is the $3 \times 6$ piezoelectric matrix  
- $\boldsymbol{\varepsilon}^S$ is the $3 \times 3$ dielectric matrix

This is the form used in most **FEM solvers and PINN loss functions**.



## Real-World Applications

- **Actuators** – voltage → precision displacement  
- **Sensors** – strain/stress → voltage  
- **Energy harvesters** – vibration → power  
- **Ultrasound devices** – bidirectional transduction  
- **MEMS and NEMS** – integrated electromechanical control

---
> **Note:** If you spot any errors or have suggestions for improvement, please feel free to write to us in our **members-only chat**. We’ll be happy to update and improve the material for everyone’s benefit.

Thanks and Happy Learning  
Team Elastropy