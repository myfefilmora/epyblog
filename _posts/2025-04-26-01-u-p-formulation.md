---
layout: post
# author: "Epy Blog"
title: "u–p Formulation for Incompressible Solids: From Deriving Full Governing Equations to FEM Matrices"
tags:
  - Finite Element Analysis
usemathjax:     true
more_updates_card: true
excerpt_separator: <!--more-->
---

In solid mechanics, we usually solve problems by calculating **displacements** — how every point inside a solid moves when forces are applied. <!--more-->

Once we know how the solid deforms, we compute **strain** (how much it stretches or compresses), and from that, we compute **stress** (how much internal force builds up).

This process works well for many materials: steel, concrete, aluminum — anything that behaves like a regular elastic solid.

But this approach begins to fail for **incompressible materials**.

<div class="alert" role="alert" style="background-color: #fff3cd; border-left: 6px solid #ffeeba; padding: 1rem; font-size: 1rem; text-align:justify;">
  <strong>Disclaimer:</strong> While this post provides a complete first-principles derivation of the governing equations, boundary conditions, and FEM matrix formulation, certain implementation-level details (such as Jacobian mapping, numerical integration, and data structures) are intentionally abstracted.
  <br><br>
  As a result, this post is <strong>not intended as a direct coding guide</strong>, but rather as a conceptual and intuitive resource to help readers <strong>understand the mathematical structure</strong> of u–p Formulation for Incompressible Solids. Some gaps may remain from theory to code — and that’s okay. This post is meant to build the foundation.
</div>

### What does “incompressible” really mean?

Incompressible materials **don’t want to change their volume**.

You can bend, twist, stretch them — but they’ll do everything they can to keep their volume the same.  
Examples include:
- Rubber
- Wet clay
- Some foams
- Biological tissues
- Fluids trapped inside solids (e.g., saturated soil)

In mathematical terms, they try to satisfy:
$$
\frac{\partial u_1}{\partial x_1} + \frac{\partial u_2}{\partial x_2} + \frac{\partial u_3}{\partial x_3} \approx 0
$$

This is the **volumetric strain**, and it tells us how much the material is expanding or compressing.



### Why does standard FEM fail here?

When you use the usual FEM formulation (displacement-based), and the material is nearly incompressible, the simulation:
- Becomes way too stiff  
- Can't deform properly  
- Produces zero or meaningless displacement  
- Fails to represent the real physics

This issue is known as **volumetric locking**.

To fix it, we change our strategy.



## The Key Idea: Let Pressure Handle Volume

Instead of trying to force incompressibility by tweaking the material stiffness, we take a smarter route:

> We introduce **pressure** as a second unknown in our equations.

This gives us a **mixed formulation**, where we solve for:
- Displacement $ u_i $: how the body deforms  
- Pressure $ p $: how the volume resists compression

This is called the **u–p formulation**.

Now let’s build it slowly, step by step.


## What is covered in this post?

- **Part 1:** Understand the physical reasons behind the u–p formulation and derive the governing equations.
- **Part 2:** Derive the weak form and learn how to discretize using finite elements (Considering 8-Node Hexahedral Element).

Each part is designed to explain both the physics and the FEM implementation steps intuitively, with detailed but beginner-friendly derivations. Let's start with Part-1,


## Part 1 - Understand the physical reasons behind the u–p formulation and derive the governing equations.

In this part, we will build the u–p formulation from the ground up step-by-step, starting with basic physical principles. We’ll first revisit how forces and stresses are balanced inside a solid, then see how the stress tensor can be separated into shape-changing and volume-changing parts. 

Finally, we’ll introduce pressure as a new unknown and derive the full set of governing equations that form the backbone of the u–p formulation.

## Step 1: Force Balance – Always Start with Newton

At every point in a solid, the internal stresses and external forces must be in balance. This is Newton’s second law applied to a deformable solid:

$$
\frac{\partial \sigma_{ij}}{\partial x_j} + b_i = 0
$$

Where:
- $ \sigma_{ij} $: the Cauchy stress tensor — how much internal force exists  
- $ b_i $: body force per unit volume (like gravity)  
- The term $ \frac{\partial \sigma_{ij}}{\partial x_j} $ measures how that stress varies across space

This equation is called the **momentum balance**, and it must hold at every point inside the solid.

This is our first governing equation.



## Step 2: How Do We Define Stress?

In linear elasticity, stress is computed from strain as:

$$
\sigma_{ij} = \lambda \, \varepsilon_{kk} \delta_{ij} + 2\mu \, \varepsilon_{ij}
$$

This is Hooke’s law for 3D solids.

Let’s unpack what this means:
- $ \lambda $ and $ \mu $ are **Lamé constants** (material properties)  
- $ \varepsilon_{ij} $ is the **strain tensor**, computed from displacement:
  $$
  \varepsilon_{ij} = \frac{1}{2} \left( \frac{\partial u_i}{\partial x_j} + \frac{\partial u_j}{\partial x_i} \right)
  $$
- $ \varepsilon_{kk} = \frac{\partial u_1}{\partial x_1} + \frac{\partial u_2}{\partial x_2} + \frac{\partial u_3}{\partial x_3} $  
  This is the **volumetric strain** (how much volume is changing)  
- $ \delta_{ij} $ is 1 when $ i = j $, 0 otherwise

So:
- The first term $ \lambda \varepsilon_{kk} \delta_{ij} $ represents **volumetric stress**
- The second term $ 2\mu \varepsilon_{ij} $ represents **shape-changing (shear) stress**

Now we’re going to split this stress expression to handle these two effects more clearly.



## Step 3: Separating Stress into Two Parts

Let’s now write the total stress as:

$$
\sigma_{ij} = s_{ij} - p \, \delta_{ij}
$$

This is a **key idea** in the u–p formulation:
- $ s_{ij} $: **deviatoric stress** — handles shape changes (distortion)
- $ p $: **pressure** — handles volume changes (compression or expansion)

The minus sign is important, and here’s why:



### Why is pressure negative in this definition?

We define:
$$
p = -\lambda \, \varepsilon_{kk}
$$

So, if the material **compresses** (volume decreases), $ \varepsilon_{kk} < 0 $, and $ p > 0 $ — pressure is positive.

If the material **expands**, $ \varepsilon_{kk} > 0 $, and $ p < 0 $ — pressure is negative.

That’s how pressure works in physics:  
> **Compression → positive pressure**, **expansion → negative pressure**

This negative sign ensures that pressure behaves naturally — just like in a balloon.



## Step 4: Define Deviatoric Stress

Now that we’ve defined pressure, we subtract the volume part from total strain to get **deviatoric strain**:

$$
e_{ij} = \varepsilon_{ij} - \frac{1}{3} \varepsilon_{kk} \delta_{ij}
$$

This removes the isotropic (volume-changing) part of the strain tensor.

Then we define:
$$
s_{ij} = 2\mu \, e_{ij}
$$

So total stress becomes:
$$
\sigma_{ij} = 2\mu \left( \varepsilon_{ij} - \frac{1}{3} \varepsilon_{kk} \delta_{ij} \right) - p \delta_{ij}
$$

You can now clearly see how we’re separating the stress into:
- A **shear (shape) part**  
- A **pressure (volume) part**

This separation makes it much easier to control each effect independently in FEM.



## Step 5: Treat Pressure as an Unknown

In the standard formulation, you’d compute pressure from displacement:

$$
p = -\lambda \, \frac{\partial u_k}{\partial x_k}
$$

But in the u–p formulation, we **do not substitute this into the stress**.

Instead, we treat $ p $ as a **second field variable** — like a temperature or voltage — and we **solve for it**.

That means we now have a **second equation**:

$$
\frac{\partial u_k}{\partial x_k} + \frac{p}{\lambda} = 0
$$

This is called the **volumetric constraint equation**, and it enforces how pressure and volume are coupled.



## Part-1 Summary: The Strong Form of u–p Formulation

### **Unknowns**:
- Displacement vector field $ u_i(x) $
- Pressure scalar field $ p(x) $



### **Governing Equations:**

1. **Momentum Balance (equilibrium):**
$$
\frac{\partial s_{ij}}{\partial x_j} - \frac{\partial p}{\partial x_i} + b_i = 0 \quad \text{in } \Omega
$$

Where:
$$
s_{ij} = 2\mu \left( \varepsilon_{ij} - \frac{1}{3} \varepsilon_{kk} \delta_{ij} \right)
$$

2. **Volumetric Constraint:**
$$
\frac{\partial u_k}{\partial x_k} + \frac{p}{\lambda} = 0 \quad \text{in } \Omega
$$



### **Boundary Conditions:**

- **Displacement BC**: $ u_i = \bar{u}_i $ on $ \Gamma_u $
- **Traction BC**: $ \sigma_{ij} n_j = \bar{t}_i $ on $ \Gamma_t $
- For pressure, set it at a point or apply natural BCs as needed



That’s the complete, intuitive derivation of the **governing equations for the u–p formulation**.

## Part 2: Derive the weak form and learn how to discretize using finite elements (Considering 8-Node Hexahedral Element).

In Part 1, we derived the governing equations of the u–p formulation. We saw how we split the total stress into deviatoric and pressure parts, and introduced pressure as a second unknown field.

Now let’s see how to actually solve these equations using the **finite element method (FEM)**.

We'll walk through:
- Weak form derivation
- Shape functions
- Matrix expressions
- Final assembled system

Our goal is to eventually build the element matrices for an 8-node brick element (also called a Q8 or hexahedral element).

Let’s go slowly and explain every step.



## Step 1: What Do We Want to Solve?

We have two field variables:
- Displacement: $ u_i(x) $
- Pressure: $ p(x) $

And two governing equations:
1. **Momentum balance** (modified):
   $$
   \frac{\partial s_{ij}}{\partial x_j} - \frac{\partial p}{\partial x_i} + b_i = 0
   $$
2. **Volumetric constraint**:
   $$
   \frac{\partial u_k}{\partial x_k} + \frac{p}{\lambda} = 0
   $$

The idea in FEM is:
- Multiply each equation by a test function (virtual displacement or virtual pressure)
- Integrate over the domain
- Apply integration by parts where needed

Let’s do that step by step.



## Step 2: Weak Form of the Momentum Equation

We start by multiplying the first equation by a virtual displacement $ \delta u_i $ and integrating:

$$
\int_\Omega \delta u_i \left( \frac{\partial s_{ij}}{\partial x_j} - \frac{\partial p}{\partial x_i} + b_i \right) d\Omega = 0
$$

Now apply integration by parts to the first term:

$$
\int_\Omega \delta u_i \frac{\partial s_{ij}}{\partial x_j} d\Omega 
= -\int_\Omega \frac{\partial \delta u_i}{\partial x_j} s_{ij} d\Omega 
+ \int_{\Gamma_t} \delta u_i \bar{t}_i \, d\Gamma
$$

So the weak form becomes:

$$
\int_\Omega \frac{\partial \delta u_i}{\partial x_j} s_{ij} \, d\Omega 
+ \int_\Omega \frac{\partial \delta u_i}{\partial x_i} p \, d\Omega 
= \int_\Omega \delta u_i b_i \, d\Omega 
+ \int_{\Gamma_t} \delta u_i \bar{t}_i \, d\Gamma
$$

Let’s understand the terms:
- The first term comes from the **deviatoric stress**
- The second term comes from the **pressure**
- The right-hand side is the external work (body force + traction)



## Step 3: Weak Form of the Volumetric Constraint

We now multiply the volumetric constraint equation by a test function $ \delta p $ and integrate:

$$
\int_\Omega \delta p \left( \frac{\partial u_k}{\partial x_k} + \frac{p}{\lambda} \right) d\Omega = 0
$$

This equation links displacement divergence to pressure.



So now we have two weak form equations:

### (a) Displacement equation:

$$
\int_\Omega \frac{\partial \delta u_i}{\partial x_j} s_{ij} \, d\Omega 
+ \int_\Omega \frac{\partial \delta u_i}{\partial x_i} p \, d\Omega 
= \int_\Omega \delta u_i b_i \, d\Omega 
+ \int_{\Gamma_t} \delta u_i \bar{t}_i \, d\Gamma
$$

### (b) Pressure equation:

$$
\int_\Omega \delta p \, \frac{\partial u_k}{\partial x_k} \, d\Omega 
+ \int_\Omega \delta p \, \frac{p}{\lambda} \, d\Omega = 0
$$

Now let’s discretize.



## Step 4: Interpolation Using Shape Functions

We now express the unknowns $ u_i $ and $ p $ in terms of **finite element shape functions**.

Assume we use an 8-node hexahedral (brick) element. Each node has:
- 3 displacement DOFs $ (u_x, u_y, u_z) $
- Pressure DOFs may be:
  - At the same 8 nodes (Q8-Q8)
  - Or reduced (Q8-Q1: one pressure value per element)

Let’s denote:
- $ N_a(x) $: shape function for displacement at node $ a $  
- $ M_b(x) $: shape function for pressure at node $ b $

Then:
$$
u_i(x) = \sum_a N_a(x) \, u_i^a, \quad 
p(x) = \sum_b M_b(x) \, p^b
$$

Similarly:
- $ \delta u_i(x) = \sum_a N_a(x) \, \delta u_i^a $
- $ \delta p(x) = \sum_b M_b(x) \, \delta p^b $

We now substitute these into the weak forms.



## Step 5: Matrix Expressions (Element Level)

In this step, we express the matrices that arise after discretizing the weak forms using finite element interpolation.

We first define the basic interpolation fields:
- $ N_a(x) $: Shape function associated with **displacement** at node $ a $
- $ M_b(x) $: Shape function associated with **pressure** at node $ b $

For a Q8-Q1 element:
- Displacement uses **8-node interpolation** (quadratic).
- Pressure uses **1-node interpolation** (constant inside element).



### (a) Strain-Displacement Matrix $ \mathbf{B}_u $

The displacement field is approximated as:

$$
u_i(x) = \sum_a N_a(x) u_i^a
$$

Thus, the strain tensor becomes:

$$
\varepsilon_{ij} = \sum_a \frac{1}{2} \left( \frac{\partial N_a}{\partial x_j} u_i^a + \frac{\partial N_a}{\partial x_i} u_j^a \right)
$$

This defines the **strain-displacement matrix** $ \mathbf{B}_u $, which relates nodal displacements to strains.

- For an 8-node hexahedral element:
  - $ \mathbf{B}_u $ has size **6 × 24** (6 strains × 3 DOFs × 8 nodes).



### (b) Volumetric Strain Operator Matrix $ \mathbf{B}_v $

The **volumetric strain** (divergence of displacement) is given by:

$$
\varepsilon_{kk} = \frac{\partial u_1}{\partial x} + \frac{\partial u_2}{\partial y} + \frac{\partial u_3}{\partial z}
$$

Substituting the displacement interpolation:

$$
\frac{\partial u_k}{\partial x_k} = \sum_a \left( \frac{\partial N_a}{\partial x} u_1^a + \frac{\partial N_a}{\partial y} u_2^a + \frac{\partial N_a}{\partial z} u_3^a \right)
$$

We define the **volumetric operator matrix** $ \mathbf{B}_v $ as:

$$
\mathbf{B}_v =
\begin{bmatrix}
\frac{\partial N_1}{\partial x} & \frac{\partial N_1}{\partial y} & \frac{\partial N_1}{\partial z} &
\cdots &
\frac{\partial N_8}{\partial x} & \frac{\partial N_8}{\partial y} & \frac{\partial N_8}{\partial z}
\end{bmatrix}
$$

- $ \mathbf{B}_v $ is a **1 × 24** matrix.
- Each node contributes 3 terms: $ \partial N_a/\partial x $, $ \partial N_a/\partial y $, $ \partial N_a/\partial z $.



### (c) Pressure Shape Function $ M(x) $

The pressure field is interpolated using shape functions $ M_b(x) $ as:

$$
p(x) = \sum_b M_b(x) p^b
$$

For the Q1 element:
- $ M(x) = 1 $ (constant inside the element).
- There is **one pressure DOF** per element.



### Element Matrices Derived from the Weak Forms

Using the above interpolation fields, we now express the element-level matrices.



#### 1. Displacement Stiffness Matrix $ \mathbf{K}_{uu} $

This matrix comes from the deviatoric (shape-changing) part of stress:

$$
\mathbf{K}_{uu} = \int_{\Omega^e} \mathbf{B}_d^T \, \mathbf{C}_d \, \mathbf{B}_d \, d\Omega
$$

where:
- $ \mathbf{B}_d $ is the deviatoric part of $ \mathbf{B}_u $ (removing volumetric component).
- $ \mathbf{C}_d $ is the deviatoric constitutive matrix, typically:

$$
\mathbf{C}_d = 2\mu \mathbf{I}
$$



#### 2. Displacement–Pressure Coupling Matrix $ \mathbf{K}_{up} $

This matrix arises from the coupling of displacement volumetric strain and pressure.

From the weak form:

$$
\mathbf{K}_{up} = \int_{\Omega^e} \mathbf{B}_v^T M(x) \, d\Omega
$$

Since $ M(x) = 1 $:

$$
\mathbf{K}_{up} = \int_{\Omega^e} \mathbf{B}_v^T \, d\Omega
$$

✅ $ \mathbf{K}_{up} $ is a **24 × 1** matrix.

Each entry represents how the divergence of a displacement DOF couples to pressure.



#### 3. Pressure–Displacement Coupling Matrix $ \mathbf{K}_{pu} $

This is simply the transpose of $ \mathbf{K}_{up} $:

$$
\mathbf{K}_{pu} = \left( \mathbf{K}_{up} \right)^T
$$

✅ $ \mathbf{K}_{pu} $ is a **1 × 24** matrix.

This ensures symmetry in the assembled global matrix.



#### 4. Pressure Stiffness Matrix $ \mathbf{K}_{pp} $

This comes from the pressure-pressure coupling in the volumetric constraint:

$$
\mathbf{K}_{pp} = \int_{\Omega^e} \frac{1}{\lambda} M(x)^T M(x) \, d\Omega
$$

Since $ M(x) = 1 $, we get:

$$
\mathbf{K}_{pp} = \frac{V_e}{\lambda}
$$

where:
- $ V_e $ is the **volume of the element**.

✅ $ \mathbf{K}_{pp} $ is a **scalar** (1 × 1 matrix).



### Final Element Matrix Structure

Thus, the element system for each brick element becomes:

$$
\begin{bmatrix}
\mathbf{K}_{uu} & \mathbf{K}_{up} \\
\mathbf{K}_{pu} & \mathbf{K}_{pp}
\end{bmatrix}
\begin{Bmatrix}
\mathbf{u} \\
p
\end{Bmatrix}
=
\begin{Bmatrix}
\mathbf{f}_u \\
0
\end{Bmatrix}
$$

Where:
- $ \mathbf{f}_u $ is the standard body force and traction contribution.
- The zero on the right side corresponds to enforcing the volumetric constraint.

This is what you will assemble for each element. This system allows you to simulate incompressible materials without locking.



## **Symbolic Structure of $ \mathbf{B}_v $**

The matrix $ \mathbf{B}_v $ extracts the **volumetric strain** from the displacement field, i.e., it computes:

$$
\varepsilon_{kk} = \frac{\partial u_x}{\partial x} + \frac{\partial u_y}{\partial y} + \frac{\partial u_z}{\partial z}
$$

For a brick element with 8 nodes, there are **24 DOFs** arranged as:

$$
\mathbf{u}_e = \begin{bmatrix}
u_x^1 & u_y^1 & u_z^1 & u_x^2 & u_y^2 & u_z^2 & \cdots & u_x^8 & u_y^8 & u_z^8
\end{bmatrix}^T
$$

Let $ N_1, N_2, ..., N_8 $ be the displacement shape functions. Then, the symbolic structure of $ \mathbf{B}_v $ is:

$$
\mathbf{B}_v = \begin{bmatrix}
\frac{\partial N_1}{\partial x} & \frac{\partial N_1}{\partial y} & \frac{\partial N_1}{\partial z} &
\cdots &
\frac{\partial N_8}{\partial x} & \frac{\partial N_8}{\partial y} & \frac{\partial N_8}{\partial z}
\end{bmatrix}
$$

It is a **1×24** row matrix.

Each node contributes 3 entries (∂/∂x, ∂/∂y, ∂/∂z of its shape function).



## **Symbolic Structure of $ \mathbf{K}_{up} $**

This is the matrix that links **pressure and displacement**.

It comes from this weak form term:

$$
\int_{\Omega^e} \left( \frac{\partial \delta u_k}{\partial x_k} \right) p \, d\Omega
\quad \Rightarrow \quad
\mathbf{K}_{up} = \int_{\Omega^e} \mathbf{B}_v^T \cdot 1 \, d\Omega
$$

Assuming pressure shape function is **1 (constant)** inside the element (Q1), the matrix becomes:

$$
\mathbf{K}_{up} = \int_{\Omega^e} \mathbf{B}_v^T \, d\Omega
$$

So its symbolic form is:

$$
\mathbf{K}_{up} =
\begin{bmatrix}
\int \frac{\partial N_1}{\partial x} \, d\Omega \\
\int \frac{\partial N_1}{\partial y} \, d\Omega \\
\int \frac{\partial N_1}{\partial z} \, d\Omega \\
\vdots \\
\int \frac{\partial N_8}{\partial x} \, d\Omega \\
\int \frac{\partial N_8}{\partial y} \, d\Omega \\
\int \frac{\partial N_8}{\partial z} \, d\Omega
\end{bmatrix}_{24 \times 1}
$$

Each group of 3 rows corresponds to a node — one entry for each spatial direction.

So the full symbolic structure is:

$$
\mathbf{K}_{up} =
\begin{bmatrix}
\int \frac{\partial N_1}{\partial x} \\
\int \frac{\partial N_1}{\partial y} \\
\int \frac{\partial N_1}{\partial z} \\
\int \frac{\partial N_2}{\partial x} \\
\int \frac{\partial N_2}{\partial y} \\
\int \frac{\partial N_2}{\partial z} \\
\vdots \\
\int \frac{\partial N_8}{\partial x} \\
\int \frac{\partial N_8}{\partial y} \\
\int \frac{\partial N_8}{\partial z}
\end{bmatrix}
$$

## Part-2 Summary: The Weak Form of u–p Formulation and Element Matrices for an 8-Node Hexahedral (Brick) Element

- The u–p formulation gives us **two coupled weak form equations**  
- We discretize displacement and pressure using shape functions  
- This leads to a **block matrix system**:
  - Top row: momentum balance
  - Bottom row: incompressibility constraint
- The matrices are built from the **same ingredients** as standard FEM, but with some new terms for pressure coupling
- The Q8-Q1 element uses 8 nodes with 3 DOFs each for displacement (total 24)  
- A single pressure DOF is added per element  
- The resulting element matrix is 25×25, with blocks:
  - $ \mathbf{K}_{uu} $: shape-change stiffness
  - $ \mathbf{K}_{up} $: pressure–displacement coupling
  - $ \mathbf{K}_{pp} $: pressure penalty term (stabilizes pressure)
- $ \mathbf{B}_v $ is a 1×24 row matrix that collects the divergence of all nodal shape functions  
- $ \mathbf{K}_{up} $ is a 24×1 column matrix that integrates the divergence coupling with pressure  
- Together, they couple the pressure degree of freedom to all displacement DOFs in the element  
<ul><li><span>$ \mathbf{K}_{pu} = \mathbf{K}_{up}^T $</span>  is 1×24, and ensures symmetry </li></ul>


This structure makes the **incompressibility condition** (volumetric constraint) act across the entire element volume.


## 📚 Final Summary

In this complete tutorial, we carefully derived the **u–p formulation** for incompressible solids, starting from the basic principles of solid mechanics.

We walked through:
- Why standard displacement-only FEM struggles with incompressibility (volumetric locking)
- How to introduce **pressure as an independent field variable** alongside displacement
- How to **separate stress** into deviatoric and volumetric parts
- How to derive the **weak forms** of the modified governing equations
- How to discretize using **8-node brick elements (Q8-Q1)**
- How to assemble the **final coupled FEM matrices**, clearly explaining the structure of <span>$ \mathbf{B}_v $</span>, <span>$ \mathbf{K}_{up} $</span>, and <span>$ \mathbf{K}_{pp} $</span>

This post aims to provide an **intuitive, beginner-friendly, yet technically complete** view of how mixed FEM formulations (like u–p) work in practice.

While we have explained every concept carefully, real-world FEM implementation still requires handling topics like:
- Stabilization (for inf-sup conditions)
- Boundary conditions for pressure
- Efficient numerical integration

We’ll cover these practical aspects in future posts.

---
> **Note:**  
> This post was developed with structured human domain expertise, supported by AI for clarity and organization.  
> Despite careful construction, subtle errors or gaps may exist. If you spot anything unclear or have suggestions, please reach out via our members-only chat — your feedback helps us make this resource even better for everyone!


