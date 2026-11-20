# Draws the site's DNA background (images/helix.svg): one long double helix
# built from small points joined by thin lines (a "molecular network" look),
# with base pairs as chains of beads in complementary colours.
#
# Usage:  awk -f scripts/make-helix.awk > images/helix.svg
#
# The helix runs horizontally in the SVG; styles.css rotates and sizes it.
# Change the seed for a different random arrangement of points.

function rnd(a, b) { return a + (b - a) * rand() }
function layer(z) {                      # depth -> drawing layer (0 = back)
  l = int((z + ZMAX) / (2 * ZMAX) * NL); return l < 0 ? 0 : (l >= NL ? NL - 1 : l)
}
function addnode(s, x, y, z) {
  n = ++N[s]; NX[s, n] = x; NY[s, n] = y; NZ[s, n] = z
}

BEGIN {
  srand(20261120)
  # Geometry (SVG units). B-DNA proportions: pitch ~1.7 x diameter, 10.5 bp/turn
  L = 4800; H = 640; cy = H / 2
  R = 220; P = 748; BP = P / 10.5
  pi = atan2(0, -1); PHI = 0.75 * pi     # strand offset -> major/minor groove
  TUBE = 20                               # radius of the point cloud around each strand
  NL = 6; ZMAX = R + TUBE
  col[0] = "#19e3ff"; col[1] = "#ff2bd6"  # strand colours (cyan, magenta)
  # base colours: A/T and G/C pairs get complementary colours
  base["A"] = "#19e3ff"; base["T"] = "#ff2bd6"; base["G"] = "#f2ff1f"; base["C"] = "#8f7cff"
  pair["A"] = "T"; pair["T"] = "A"; pair["G"] = "C"; pair["C"] = "G"
  split("A T G C", ACGT, " ")

  # 1) backbone point clouds
  for (s = 0; s < 2; s++) {
    off = s * PHI
    for (x = -40; x <= L + 40; x += 5) {
      t = 2 * pi * x / P + off
      for (k = 0; k < 2; k++) {
        # random point inside a small sphere around the strand centre line
        do { jx = rnd(-1, 1); jy = rnd(-1, 1); jz = rnd(-1, 1) } while (jx*jx + jy*jy + jz*jz > 1)
        addnode(s, x + jx * TUBE, cy + R * cos(t) + jy * TUBE, R * sin(t) + jz * TUBE)
      }
    }
  }

  # 2) link nearby points of the same strand (plexus-style network)
  for (s = 0; s < 2; s++) {
    for (i = 1; i <= N[s]; i++) {
      links = 0
      for (j = i + 1; j <= N[s] && j <= i + 14 && links < 3; j++) {
        dx = NX[s, j] - NX[s, i]; dy = NY[s, j] - NY[s, i]; dz = NZ[s, j] - NZ[s, i]
        if (dx*dx + dy*dy + dz*dz < 30 * 30) {
          l = layer((NZ[s, i] + NZ[s, j]) / 2)
          LINK[l, s] = LINK[l, s] sprintf("M%d %dL%d %d", NX[s, i], NY[s, i], NX[s, j], NY[s, j])
          links++
        }
      }
      l = layer(NZ[s, i])
      DOT[l, s] = DOT[l, s] sprintf("M%d %dh0", NX[s, i], NY[s, i])
    }
  }

  # 3) base pairs: a chain of beads across the helix
  for (x = BP / 2; x < L; x += BP) {
    t = 2 * pi * x / P
    ya = cy + R * cos(t); za = R * sin(t)
    yb = cy + R * cos(t + PHI); zb = R * sin(t + PHI)
    b1 = ACGT[int(rnd(1, 5))]; b2 = pair[b1]
    nb = 7; px = -1
    for (k = 1; k <= nb; k++) {
      f = k / (nb + 1)
      bx = x + rnd(-3, 3); by = ya + (yb - ya) * f + rnd(-3, 3); bz = za + (zb - za) * f
      c = (f < 0.5) ? b1 : b2
      l = layer(bz)
      BEAD[l, c] = BEAD[l, c] sprintf("M%d %dh0", bx, by)
      if (px >= 0) RUNG[layer((bz + pz) / 2)] = RUNG[layer((bz + pz) / 2)] sprintf("M%d %dL%d %d", px, py, bx, by)
      px = bx; py = by; pz = bz
    }
  }

  # 4) write SVG, back layers first; nearer = bigger, brighter
  printf "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\" fill=\"none\" stroke-linecap=\"round\">\n", L, H, L, H
  for (l = 0; l < NL; l++) {
    d = l / (NL - 1)                      # 0 = back, 1 = front
    op = 0.22 + 0.78 * d
    printf "<g stroke-opacity=\"%.2f\">\n", op
    if (RUNG[l] != "") printf "<path d=\"%s\" stroke=\"#b9c6ff\" stroke-width=\"%.1f\" stroke-opacity=\"%.2f\"/>\n", RUNG[l], 1.2 + 1.2 * d, 0.35 * op
    for (s = 0; s < 2; s++) {
      if (LINK[l, s] != "") printf "<path d=\"%s\" stroke=\"%s\" stroke-width=\"%.1f\" stroke-opacity=\"%.2f\"/>\n", LINK[l, s], col[s], 0.9 + 1.0 * d, 0.45 * op
      if (DOT[l, s] != "" && d > 0.5) printf "<path d=\"%s\" stroke=\"%s\" stroke-width=\"%.1f\" stroke-opacity=\"%.2f\"/>\n", DOT[l, s], col[s], 3 * (3 + 4 * d), 0.10 * op
      if (DOT[l, s] != "") printf "<path d=\"%s\" stroke=\"%s\" stroke-width=\"%.1f\"/>\n", DOT[l, s], col[s], 3 + 4 * d
    }
    for (b in base) if (BEAD[l, b] != "") {
      printf "<path d=\"%s\" stroke=\"%s\" stroke-width=\"%.1f\" stroke-opacity=\"%.2f\"/>\n", BEAD[l, b], base[b], 2.6 * (6 + 6 * d), 0.10 * op
      printf "<path d=\"%s\" stroke=\"%s\" stroke-width=\"%.1f\"/>\n", BEAD[l, b], base[b], 6 + 6 * d
    }
    print "</g>"
  }
  print "</svg>"
}
