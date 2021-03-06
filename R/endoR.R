#' endoR - the endotherm model of NicheMapR
#'
#' This model implements postural and physiological thermoregulation under a given
#' environmental scenario for an organism of a specified shape and no extra body
#' parts. In this function the sequence of thermoregulatory events in the face of
#' heat stress is to first uncurl, second change flesh conductivity, third raise
#' core temprature, fourth pant and fifth sweat.
#' @encoding UTF-8
#' @param AMASS = 1, # kg
#' @param SHAPE = 4, # shape, 1 is cylinder, 2 is sphere, 3 is plate, 4 is ellipsoid
#' @param SHAPE_B_REF = 3, # initial ratio between long and short axis (-)
#' @param FURTHRMK = 0, # user-specified fur thermal conductivity (W/mK), not used if 0
#' @param ZFURD = 2E-03, # fur depth, dorsal (m)
#' @param ZFURV = 2E-03, # fur depth, ventral (m)
#' @param TC = 37, # core temperature (°C)
#' @param TCMAX = 45, # maximum core temperature (°C)
#' @param TA = 20, air temperature at local height (°C)
#' @param TGRD = TA, ground temperature (°C)
#' @param TSKY = TA, sky temperature (°C)
#' @param VEL = 0.1, wind speed (m/s)
#' @param RH = 5, relative humidity (\%)
#' @param QSOLR = 0, solar radiation, horizontal plane (W/m2)
#' @param Z = 20, zenith angle of sun (degrees from overhead)
#' @param SHADE = 0, shade level (\%)
#' @usage endoR(AMASS = 1, SHAPE = 4, SHAPE_B_REF = 3, FURTHRMK = 0, ZFURD = 2E-03, ZFURV = 2E-03, TC = 37, TCMAX = 45, TA = 20, TGRD = TA, TSKY = TA, VEL = 0.1, RH = 5, QSOLR = 0, Z = 20, SHADE = 0, NITESHAD = 0,...)
#' @export
#' @details
#' \strong{ Parameters controlling how the model runs:}\cr\cr
#' \code{DIFTOL}{ = 0.001, error tolerance for SIMULSOL (°C)}\cr\cr
#' \code{WRITE_INPUT}{ = 0, write input to csv (1 = yes)}\cr\cr
#'
#' \strong{ Environment:}\cr\cr
#' \code{TAREF}{ = TA, air temperature at reference height (°C)}\cr\cr
#' \code{ELEV}{ = 0, elevation (m)}\cr\cr
#' \code{ABSSB}{ = 0.8, solar absorptivity of substrate (fractional, 0-1)}\cr\cr
#' \code{FLTYPE}{ = 0, FLUID TYPE: 0 = AIR; 1 = FRESH WATER; 2 = SALT WATER - need's to be looked at - only invoked in main program when the dive table is set up}\cr\cr
#' \code{TCONDSB}{ = TGRD, surface temperature for conduction (°C)}\cr\cr
#' \code{TBUSH}{ = TA, bush temperature (°C)}\cr\cr
#' \code{BP}{ = -1, Pa, negatve means elevation is used}\cr\cr
#' \code{O2GAS}{ = 20.95, oxygen concentration of air (\%)}\cr\cr
#' \code{N2GAS}{ = 79.02, nitrogen concetration of air (\%)}\cr\cr
#' \code{CO2GAS}{ = 0.03, carbon dioxide concentration of air (\%)}\cr\cr
#' \code{PCTDIF}{ = 0.15, proportion of solar radiation that is diffuse (fractional, 0-1)}\cr\cr
#'
#' \strong{ Behaviour:}\cr\cr
#' \code{NITESHAD}{ = 0, flag for if animal is behaviourally seeking shade for warmth at night - remove?}\cr\cr
#' \code{FLYHR}{ = 0, is flight occuring this hour? (imposes forced evaporative loss)}\cr\cr
#' \code{UNCURL}{ = 1, allows the animal to uncurl to SHAPE_B_MAX, the value being the increment SHAPE_B is increased per iteration}\cr\cr
#' \code{RAISETC}{ = 1, turns on core temperature elevation, the value being the increment by which TC is increased per iteration}\cr\cr
#' \code{SWEAT}{ = 0.25, turns on sweating, the value being the increment by which SKINW is increased per iteration (\%)}\cr\cr
#' \code{MXWET}{ = 100, maximum surface area that can be wet (\%)}\cr\cr
#' \code{AK1inc}{ = 0.5, turns on thermal conductivity increase (W/mK), the value being the increment by which AK1 is increased per iteration (W/mC)}\cr\cr
#' \code{AKMAX}{ = 2.8, maximum flesh conductivity (W/mK)}\cr\cr
#' \code{PANT}{ = 1, multiplier on breathing rate to simulate panting (-)}\cr\cr
#' \code{PANTING}{ = 0.1, increment for multiplier on breathing rate to simulate panting (-)}\cr\cr
#'
#' \strong{ General morphology:}\cr\cr
#' \code{ANDENS}{ = 1000, body density (kg/m3)}\cr\cr
#' \code{SUBQFAT}{ = 0, is subcutaneous fat present? (0 is no, 1 is yes)}\cr\cr
#' \code{FATPCT}{ = 20, \% body fat}\cr\cr
#' \code{SHAPE_B}{ = SHAPE_B_REF, current ratio between long and short axis (-)}\cr\cr
#' \code{SHAPE_B_MAX}{ = SHAPE_B_REF, max possible ratio between long and short axis (-)}\cr\cr
#' \code{SHAPE_C}{ = SHAPE_B, current ratio of length:height (plate)}\cr\cr
#' \code{MAXPTVEN}{ = 0.5, maxium fraction of surface area that is ventral (fractional, 0-1)}\cr\cr
#' \code{PCOND}{ = 0, fraction of surface area that is touching the substrate (fractional, 0-1)}\cr\cr
#' \code{MAXPCOND}{ = 0, maximum fraction of surface area that is touching the substrate (fractional, 0-1)}\cr\cr
#' \code{SAMODE}{ = 0, if 0, uses surface area for SHAPE geometry, if 1, uses bird skin surface area allometry from Walsberg & King. 1978. JEB 76:185–189, if 2 uses mammal surface area from Stahl 1967.J. App. Physiol. 22, 453–460.}\cr\cr
#' \code{ORIENT}{ = 0, if 1 = normal to rays of sun (heat maximising), if 2 = parallel to rays of sun (heat minimising), or 0 = average}\cr\cr
#'
#' \strong{ Fur properties:}\cr\cr
#' \code{DHAIRD}{ = 30E-06, hair diameter, dorsal (m)}\cr\cr
#' \code{DHAIRV}{ = 30E-06, hair diameter, ventral (m)}\cr\cr
#' \code{LHAIRD}{ = 23.9E-03, hair length, dorsal (m)}\cr\cr
#' \code{LHAIRV}{ = 23.9E-03, hair length, ventral (m)}\cr\cr
#' \code{RHOD}{ = 3000E+04, hair density, dorsal (1/m2)}\cr\cr
#' \code{RHOV}{ = 3000E+04, hair density, ventral (1/m2)}\cr\cr
#' \code{REFLD}{ = 0.2, fur reflectivity dorsal (fractional, 0-1)}\cr\cr
#' \code{REFLV}{ = 0.2, fur reflectivity ventral (fractional, 0-1)}\cr\cr
#' \code{ZFURCOMP}{ = ZFURV, depth of compressed fur (for conduction) (m)}\cr\cr
#'
#' \strong{ Radiation exchange:}\cr\cr
#' \code{EMISAN}{ = 0.99, animal emissivity (-)}\cr\cr
#' \code{FATOBJ}{ = 0, configuration factor to nearby object}\cr\cr
#' \code{FABUSH}{ = 0, this is for veg below/around animal (at TALOC)}\cr\cr
#' \code{FGDREF}{ = 0.5, reference configuration factor to ground}\cr\cr
#' \code{FSKREF}{ = 0.5, configuration factor to sky}\cr\cr
#'
#' \strong{ Nest properties:}\cr\cr
#' \code{NESTYP}{ = 0, # for nest calculations, to do)}\cr\cr
#' \code{RoNEST}{ = 0, # for nest calculations, to do}\cr\cr
#'
#' \strong{ Physiology:}\cr\cr
#' \code{AK1}{ = 0.9, # initial thermal conductivity of flesh (0.412 - 2.8 W/mK)}\cr\cr
#' \code{AK2}{ = 0.230, # conductivity of fat (W/mK)}\cr\cr
#' \code{QBASAL}{ = (70 \* AMASS ^ 0.75) \* (4.185 / (24 \* 3.6)), # basal heat generation (W)}\cr\cr
#' \code{SKINW}{ = 0.5, # part of the skin surface that is wet (\%)}\cr\cr
#' \code{FURWET}{ = 0, # Area of fur/feathers that is wet after rain (\%)}\cr\cr
#' \code{PCTBAREVAP}{ = 0, surface area for evaporation that is skin, e.g. licking paws (\%)}\cr\cr
#' \code{PCTEYES}{ = 0, # surface area made up by the eye (\%) - make zero if sleeping}\cr\cr
#' \code{DELTAR}{ = 0, # offset between air temperature and breath (°C)}\cr\cr
#' \code{RELXIT}{ = 100, # relative humidity of exhaled air, \%}\cr\cr
#' \code{TIMACT}{ = 1, # multiplier on metabolic rate for activity costs}\cr\cr
#' \code{RQ}{ = 0.80, # respiratory quotient (fractional, 0-1)}\cr\cr
#' \code{EXTREF}{ = 20, # O2 extraction efficiency (\%)}\cr\cr
#' \code{PANTMAX}{ = 10, # maximum breathing rate multiplier to simulate panting (-)}\cr\cr
#' \code{Q10}{ = 1, # Q10 factor for adjusting BMR for TC}\cr\cr
#'
#' \strong{ Initial conditions:}\cr\cr
#' \code{TS}{ = TC - 3, # initial skin temperature (°C)}\cr\cr
#' \code{TFA}{ = TA, # initial fur/air interface temperature (°C)}\cr\cr
#'
#' \strong{Outputs:}
#'
#' treg variables (thermoregulatory response):
#' \itemize{
#' \item 1 TC - core temperature (°C)
#' \item 2 TLUNG - lung temperature (°C)
#' \item 3 TSKIN_D - dorsal skin temperature (°C)
#' \item 4 TSKIN_V - ventral skin temperature (°C)
#' \item 5 TFA_D - dorsal fur-air interface temperature (°C)
#' \item 6 TFA_V - ventral fur-air interface temperature (°C)
#' \item 7 SHAPE_B - current ratio between long and short axis due to postural change (-)
#' \item 8 PANT - breathing rate multiplier (-)
#' \item 9 SKINWET - part of the skin surface that is wet (\%)
#' \item 10 K_FLESH - thermal conductivity of flesh (W/mC)
#' \item 11 K_FUR - thermal conductivity of flesh (W/mC)
#' \item 12 K_FUR_D - thermal conductivity of dorsal fur (W/mC)
#' \item 13 K_FUR_V - thermal conductivity of ventral fur (W/mC)
#' \item 14 K_COMPFUR - thermal conductivity of compressed fur (W/mC)
#' \item 15 Q10 - Q10 multiplier on metabolic rate (-)
#' }
#' morph variables (morphological traits):
#' \itemize{
#' \item 1 AREA - total outer surface area (m2)
#' \item 2 VOLUME - total volume (m3)
#' \item 3 CHAR_DIM  - characteristic dimension for convection (m)
#' \item 4 MASS_FAT - fat mass (kg)
#' \item 5 FAT_THICK - thickness of fat layer (m)
#' \item 6 FLESH_VOL - flesh volume (m3)
#' \item 7 LENGTH - length (m)
#' \item 8 WIDTH - width (m)
#' \item 9 HEIGHT - height (m)
#' \item 10 DIAM_FLESH - diameter, core to skin (m)
#' \item 11 DIAM_FUR - diameter, core to fur (m)
#' \item 12 AREA_SIL - silhouette area (m2)
#' \item 13 AREA_SILN - silhouette area normal to sun's rays (m2)
#' \item 14 AREA_ASILP - silhouette area parallel to sun's rays (m2)
#' \item 15 AREA_SKIN - total skin area (m2)
#' \item 16 AREA_SKIN_EVAP - skin area available for evaporation (m2)
#' \item 17 AREA_CONV - area for convection (m2)
#' \item 18 AREA_COND - area for conduction (m2)
#' \item 19 F_SKY - configuration factor to sky (-)
#' \item 20 F_GROUND - configuration factor to ground (-)
#' }
#' enbal variables (energy balance):
#' \itemize{
#' \item 1 QSOL - solar radiation absorbed (W)
#' \item 2 QIRIN - longwave (infra-red) radiation absorbed (W)
#' \item 3 QMET  - metabolic heat production (W)
#' \item 4 QEVAP - evaporation (W)
#' \item 5 QIROUT - longwave (infra-red) radiation lost (W)
#' \item 6 QCONV - convection (W)
#' \item 7 QCOND - conduction (W)
#' \item 8 ENB - energy balance (W)
#' \item 9 NTRY - iterations required for a solution (-)
#' \item 10 SUCCESS - was a solution found (0=no, 1=yes)
#' }
#' masbal variables (mass exchanges):
#' \itemize{
#' \item 1 AIR_L - breating rate (L/h)
#' \item 2 O2_L - oxgyen consumption rate (L/h)
#' \item 3 H2OResp_g - respiratory water loss (g/h)
#' \item 4 H2OCut_g - cutaneous water loss (g/h)
#' \item 5 O2_mol_in - oxygen inhaled (mol/h)
#' \item 6 O2_mol_out - oxygen expelled (mol/h)
#' \item 7 N2_mol_in - nitrogen inhaled (mol/h)
#' \item 8 N2_mol_out - nitrogen expelled (mol/h)
#' \item 9 AIR_mol_in - air inhaled (mol/h)
#' \item 10 AIR_mol_out - air expelled (mol/h)
#' }
#' @examples
#' library(NicheMapR)
#' # environment
#' TAs <- seq(0, 50, 2) # air temperatures (Â°C)
#' VEL <- 0.002 # wind speed (m/s)
#' RH <- 10 # relative humidity (%)
#' QSOLR <- 100 # solar radiation (W/m2)
#'
#' # core temperature
#' TC <- 38 # core temperature (deg C)
#' TCMAX <- 43 # maximum core temperature (Â°C)
#' RAISETC <- 0.25 # increment by which TC is elevated (Â°C)
#'
#' # size and shape
#' AMASS <- 0.0337 # mass (kg)
#' SHAPE_B_REF <- 1.1 # start off near to a sphere (-)
#' SHAPE_B_MAX <- 5 # maximum ratio of length to width/depth
#'
#' # fur/feather properties
#' DHAIRD = 30E-06 # hair diameter, dorsal (m)
#' DHAIRV = 30E-06 # hair diameter, ventral (m)
#' LHAIRD = 23.1E-03 # hair length, dorsal (m)
#' LHAIRV = 22.7E-03 # hair length, ventral (m)
#' ZFURD = 5.8E-03 # fur depth, dorsal (m)
#' ZFURV = 5.6E-03 # fur depth, ventral (m)
#' RHOD = 8000E+04 # hair density, dorsal (1/m2)
#' RHOV = 8000E+04 # hair density, ventral (1/m2)
#' REFLD = 0.248  # fur reflectivity dorsal (fractional, 0-1)
#' REFLV = 0.351  # fur reflectivity ventral (fractional, 0-1)
#'
#' # physiological responses
#' SKINW <- 0.1 # base skin wetness (%)
#' MXWET <- 20 # maximum skin wetness (%)
#' SWEAT <- 0.25 # intervals by which skin wetness is increased (%)
#' Q10 <- 2 # Q10 effect of body temperature on metabolic rate
#' QBASAL <- (70 \* AMASS ^ 0.75) \* (4.185 / (24 \* 3.6)) # basal heat generation (W) (bird formula from McKechnie and Wolf 2004 Phys. & Biochem. Zool. 77:502-521)
#' DELTAR <- 5 # offset between air temeprature and breath (°C)
#' EXTREF <- 15 # O2 extraction efficiency (%)
#' PANTING <- 0.1 # turns on panting, the value being the increment by which the panting multiplier is increased up to the maximum value, PANTMAX
#' PANTMAX <- 3# maximum panting rate - multiplier on air flow through the lungs above that determined by metabolic rate
#'
#' ptm <- proc.time() # start timing
#' endo.out <- lapply(1:length(TAs), function(x){endoR(TA = TAs[x], QSOLR = QSOLR, VEL = VEL, TC = TC, TCMAX = TCMAX, RH = RH, AMASS = AMASS, SHAPE_B_REF = SHAPE_B_REF, SHAPE_B_MAX = SHAPE_B_MAX, SKINW = SKINW, SWEAT = SWEAT, MXWET = MXWET, Q10 = Q10, QBASAL = QBASAL, DELTAR = DELTAR, DHAIRD = DHAIRD, DHAIRV = DHAIRV, LHAIRD = LHAIRD, LHAIRV = LHAIRV, ZFURD = ZFURD, ZFURV = ZFURV, RHOD = RHOD, RHOV = RHOV, REFLD = REFLD, RAISETC = RAISETC, PANTING = PANTING, PANTMAX = PANTMAX, EXTREF = EXTREF)}) # run endoR across environments
#' proc.time() - ptm # stop timing
#'
#' endo.out1 <- do.call("rbind", lapply(endo.out, data.frame)) # turn results into data frame
#' treg <- endo.out1[, grep(pattern = "treg", colnames(endo.out1))]
#' colnames(treg) <- gsub(colnames(treg), pattern = "treg.", replacement = "")
#' morph <- endo.out1[, grep(pattern = "morph", colnames(endo.out1))]
#' colnames(morph) <- gsub(colnames(morph), pattern = "morph.", replacement = "")
#' enbal <- endo.out1[, grep(pattern = "enbal", colnames(endo.out1))]
#' colnames(enbal) <- gsub(colnames(enbal), pattern = "enbal.", replacement = "")
#' masbal <- endo.out1[, grep(pattern = "masbal", colnames(endo.out1))]
#' colnames(masbal) <- gsub(colnames(masbal), pattern = "masbal.", replacement = "")
#'
#' QGEN <- enbal$QMET # metabolic rate (W)
#' H2O <- masbal$H2OResp_g + masbal$H2OCut_g # g/h water evaporated
#' TFA_D <- treg$TFA_D # dorsal fur surface temperature
#' TFA_V <- treg$TFA_V # ventral fur surface temperature
#' TskinD <- treg$TSKIN_D # dorsal skin temperature
#' TskinV <- treg$TSKIN_V # ventral skin temperature
#' TCs <- treg$TC # core temperature
#'
#' par(mfrow = c(2, 2))
#' par(oma = c(2, 1, 2, 2) + 0.1)
#' par(mar = c(3, 3, 1.5, 1) + 0.1)
#' par(mgp = c(2, 1, 0))
#' plot(QGEN ~ TAs, type = 'l', ylab = 'metabolic rate, W', xlab = 'air temperature, deg C', ylim = c(0.2, 1.2))
#' plot(H2O ~ TAs, type = 'l', ylab = 'water loss, g/h', xlab = 'air temperature, deg C', ylim = c(0, 1.5))
#' points(masbal$H2OResp_g ~ TAs, type = 'l', lty = 2)
#' points(masbal$H2OCut_g ~ TAs, type = 'l', lty = 2, col = 'blue')
#' legend(x = 3, y = 1.5, legend = c("total", "respiratory", "cutaneous"), col = c("black", "black", "blue"), lty = c(1, 2, 2), bty = "n")
#' plot(TFA_D ~ TAs, type = 'l', col = 'grey', ylab = 'temperature, deg C', xlab = 'air temperature, deg C', ylim = c(10, 50))
#' points(TFA_V ~ TAs, type = 'l', col = 'grey', lty = 2)
#' points(TskinD ~ TAs, type = 'l', col = 'orange')
#' points(TskinV ~ TAs, type = 'l', col = 'orange', lty = 2)
#' points(TCs ~ TAs, type = 'l', col = 'red')
#' legend(x = 30, y = 33, legend = c("core", "skin dorsal", "skin ventral", "feathers dorsal", "feathers ventral"), col = c("red", "orange", "orange", "grey", "grey"), lty = c(1, 1, 2, 1, 2), bty = "n")
#' plot(masbal$AIR_L * 1000 / 60 ~ TAs, ylim=c(0,250),  lty = 1, xlim=c(-5,50), ylab = "ml / min", xlab=paste("air temperature (deg C)"), type = 'l')
endoR <- function(
  TA = 20, # air temperature at local height (°C)
  TAREF = TA, # air temeprature at reference height (°C)
  TGRD = TA, # ground temperature (°C)
  TSKY = TA, # sky temperature (°C)
  VEL = 0.1, # wind speed (m/s)
  RH = 5, # relative humidity (%)
  QSOLR = 0, # solar radiation, horizontal plane (W/m2)
  Z = 20, # zenith angle of sun (degrees from overhead)
  ELEV = 0, # elevation (m)
  ABSSB = 0.8, # solar absorptivity of substrate (fractional, 0-1)

  # other environmental variables
  FLTYPE = 0, # FLUID TYPE: 0 = AIR; 1 = FRESH WATER; 2 = SALT WATER - need's to be looked at - only invoked in main program when the dive table is set up
  TCONDSB = TGRD, # surface temperature for conduction (°C)
  TBUSH = TA, # bush temperature (°C)
  BP = -1, # Pa, negatve means elevation is used
  O2GAS = 20.95, # oxygen concentration of air (%)
  N2GAS = 79.02, # nitrogen concetration of air (%)
  CO2GAS = 0.03, # carbon dioxide concentration of air (%)
  PCTDIF = 0.15, # proportion of solar radiation that is diffuse (fractional, 0-1)

  # BEHAVIOUR

  SHADE = 0, # shade level (%)
  NITESHAD = 0, # flag for if animal is behaviourally seeking shade for warmth at night - remove?
  FLYHR = 0, # is flight occuring this hour? (imposes forced evaporative loss)
  UNCURL = 1, # allows the animal to uncurl to SHAPE_B_MAX, the value being the increment SHAPE_B is increased per iteration
  RAISETC = 1, # turns on core temperature elevation, the value being the increment by which TC is increased per iteration
  SWEAT = 0.25, # turns on sweating, the value being the increment by which SKINW is increased per iteration
  MXWET = 100, # maximum surface area that can be wet (%)
  AK1inc = 0.5, # turns on thermal conductivity increase (W/mK), the value being the increment by which AK1 is increased per iteration
  AKMAX = 2.8, # maximum flesh conductivity (W/mK)
  PANT = 1, # multiplier on breathing rate to simulate panting (-)
  PANTING = 0.1, # increment for multiplier on breathing rate to simulate panting (-)

  # MORPHOLOGY

  # geometry
  AMASS = 1, # kg
  ANDENS = 1000, # kg/m3
  SUBQFAT = 0, # is subcutaneous fat present? (0 is no, 1 is yes)
  FATPCT = 20, # % body fat
  SHAPE = 4, # shape, 1 is cylinder, 2 is sphere, 3 is plate, 4 is ellipsoid
  SHAPE_B_REF = 3, # initial ratio between long and short axis (-)
  SHAPE_B = SHAPE_B_REF, # current ratio between long and short axis (-)
  SHAPE_B_MAX = SHAPE_B_REF, # max possible ratio between long and short axis (-)
  SHAPE_C = SHAPE_B, # ratio between length and width for plate geometry (-)}\cr\cr
  MAXPTVEN = 0.5, # maxium fraction of surface area that is ventral (fractional, 0-1)
  AWING = 0, # area of wing, to do
  PCOND = 0, # fraction of surface area that is touching the substrate (fractional, 0-1)
  MAXPCOND= 0, # maximum fraction of surface area that is touching the substrate (fractional, 0-1)
  SAMODE = 0, # if 0, uses surface area for SHAPE geometry, if 1, uses bird skin surface area allometry from Walsberg & King. 1978. JEB 76:185–189, if 2 uses mammal surface area from Stahl 1967.J. App. Physiol. 22, 453–460.
  ORIENT = 0, # if 1 = normal to sun's rays (heat maximising), if 2 = parallel to sun's rays (heat minimising), or 0 = average

  # fur properties
  FURTHRMK = 0, # user-specified fur thermal conductivity (W/mK), not used if 0
  DHAIRD = 30E-06, # hair diameter, dorsal (m)
  DHAIRV = 30E-06, # hair diameter, ventral (m)
  LHAIRD = 23.9E-03, # hair length, dorsal (m)
  LHAIRV = 23.9E-03, # hair length, ventral (m)
  ZFURD = 2E-03, # fur depth, dorsal (m)
  ZFURV = 2E-03, # fur depth, ventral (m)
  RHOD = 3000E+04, # hair density, dorsal (1/m2)
  RHOV = 3000E+04, # hair density, ventral (1/m2)
  REFLD = 0.2,  # fur reflectivity dorsal (fractional, 0-1)
  REFLV = 0.2,  # fur reflectivity ventral (fractional, 0-1)
  ZFURCOMP = ZFURV, # # depth of compressed fur (for conduction) (m)

  # radiation exchange
  EMISAN = 0.99, # animal emissivity (-)
  FATOBJ = 0, # configuration factor to nearby object
  FABUSH = 0, # this is for veg below/around animal (at TALOC)
  FGDREF = 0.5, # reference configuration factor to ground
  FSKREF = 0.5, # configuration factor to sky

  # nest properties
  NESTYP = 0, # for nest calculations, to do
  RoNEST = 0, # for nest calculations, to do

  # PHYSIOLOGY

  # thermal
  TC = 37, # core temperature (°C)
  TCMAX = 45, # maximum core temperature (°C)
  AK1 = 0.9, # initial thermal conductivity of flesh (0.412 - 2.8 W/mC)
  AK2 = 0.230, # conductivity of fat (W/mK)

  # evaporation
  SKINW = 0.5, # part of the skin surface that is wet (%)
  FURWET = 0, # part of the fur/feathers that is wet after rain (%)
  PCTBAREVAP = 0, # surface area for evaporation that is skin, e.g. licking paws (%)
  PCTEYES = 0, # surface area made up by the eye (%) - make zero if sleeping
  DELTAR = 0, # offset between air temeprature and breath (°C)
  RELXIT = 100, # relative humidity of exhaled air, %

  # metabolism/respiration
  QBASAL = (70 * AMASS ^ 0.75) * (4.185 / (24 * 3.6)), # basal heat generation (W)
  TIMACT = 1, # multiplier on metabolic rate for activity costs
  RQ = 0.80, # respiratory quotient (fractional, 0-1)
  EXTREF = 20, # O2 extraction efficiency (%)
  PANTMAX = 10, # maximum breathing rate multiplier to simulate panting (-)
  Q10 = 1, # Q10 factor for adjusting BMR for TC

  # initial conditions
  TS = TC - 3, # skin temperature (°C)
  TFA = TA, # fur/air interface temperature (°C)

  # other model settings
  DIFTOL = 0.001, # tolerance for SIMULSOL
  WRITE_INPUT = 0
){
#
#   TA = 50 # air temperature at local height (°C)
#   TAREF = TA # air temeprature at reference height (°C)
#   TGRD = TA # ground temperature (°C)
#   TSKY = TA # sky temperature (°C)
#   VEL = 0.1 # wind speed (m/s)
#   RH = 5 # relative humidity (%)
#   QSOLR = 0 # solar radiation, horizontal plane (W/m2)
#   Z = 20 # zenith angle of sun (degrees from overhead)
#   ELEV = 0 # elevation (m)
#   ABSSB = 0.8 # solar absorptivity of substrate (fractional, 0-1)
#
#   # other environmental variables
#   FLTYPE = 0 # FLUID TYPE: 0 = AIR; 1 = FRESH WATER; 2 = SALT WATER - need's to be looked at - only invoked in main program when the dive table is set up
#   TCONDSB = TGRD # surface temperature for conduction (°C)
#   TBUSH = TA # bush temperature (°C)
#   BP = -1 # Pa, negatve means elevation is used
#   O2GAS = 20.95 # oxygen concentration of air (%)
#   N2GAS = 79.02 # nitrogen concetration of air (%)
#   CO2GAS = 0.03 # carbon dioxide concentration of air (%)
#   PCTDIF = 0.15 # proportion of solar radiation that is diffuse (fractional, 0-1)
#
#   # BEHAVIOUR
#
#   SHADE = 0 # shade level (%)
#   NITESHAD = 0 # flag for if animal is behaviourally seeking shade for warmth at night - remove?
#   FLYHR = 0 # is flight occuring this hour? (imposes forced evaporative loss)
#   UNCURL = 1 # allows the animal to uncurl to SHAPE_B_MAX, the value being the increment SHAPE_B is increased per iteration
#   RAISETC = 1 # turns on core temperature elevation, the value being the increment by which TC is increased per iteration
#   SWEAT = 0.25 # turns on sweating, the value being the increment by which SKINW is increased per iteration
#   MXWET = 100 # maximum surface area that can be wet (%)
#   AK1inc = 0.5 # turns on thermal conductivity increase (W/mK), the value being the increment by which AK1 is increased per iteration
#   AKMAX = 2.8 # maximum flesh conductivity (W/mK)
#   PANT = 1 # multiplier on breathing rate to simulate panting (-)
#   PANTING = 0.1 # increment for multiplier on breathing rate to simulate panting (-)
#
#   # MORPHOLOGY
#
#   # geometry
#   AMASS = 1 # kg
#   ANDENS = 1000 # kg/m3
#   SUBQFAT = 0 # is subcutaneous fat present? (0 is no, 1 is yes)
#   FATPCT = 20 # % body fat
#   SHAPE = 4 # shape, 1 is cylinder, 2 is sphere, 3 is plate, 4 is ellipsoid
#   SHAPE_B_REF = 3 # initial ratio between long and short axis (-)
#   SHAPE_B = SHAPE_B_REF # current ratio between long and short axis (-)
#   SHAPE_B_MAX = SHAPE_B_REF # max possible ratio between long and short axis (-)
#   MAXPTVEN = 0.5 # maxium fraction of surface area that is ventral (fractional, 0-1)
#   AWING = 0 # area of wing, to do
#   PCOND = 0 # % of body area touching the substrate
#
#   # fur properties
#   FURTHRMK = 0 # user-specified fur thermal conductivity (W/mK), not used if 0
#   DHAIRD = 30E-06 # hair diameter, dorsal (m)
#   DHAIRV = 30E-06 # hair diameter, ventral (m)
#   LHAIRD = 23.9E-03 # hair length, dorsal (m)
#   LHAIRV = 23.9E-03 # hair length, ventral (m)
#   ZFURD = 2E-03 # fur depth, dorsal (m)
#   ZFURV = 2E-03 # fur depth, ventral (m)
#   RHOD = 3000E+04 # hair density, dorsal (1/m2)
#   RHOV = 3000E+04 # hair density, ventral (1/m2)
#   REFLD = 0.2  # fur reflectivity dorsal (fractional, 0-1)
#   REFLV = 0.2  # fur reflectivity ventral (fractional, 0-1)
#
#   # radiation exchange
#   EMISAN = 0.99 # animal emissivity (-)
#   FATOBJ = 0 # configuration factor to nearby object
#   FABUSH = 0 # this is for veg below/around animal (at TALOC)
#   FGDREF = 0.5 # reference configuration factor to ground
#   FSKREF = 0.5 # configuration factor to sky
#
#   # nest properties
#   NESTYP = 0 # for nest calculations, to do
#   RoNEST = 0 # for nest calculations, to do
#
#   # PHYSIOLOGY
#
#   # thermal
#   TC = 37 # core temperature (°C)
#   TCMAX = 45 # maximum core temperature (°C)
#   AK1 = 0.9 # initial thermal conductivity of flesh (0.412 - 2.8 W/mC)
#   AK2 = 0.230# conductivity of fat (W/mK)
#
#   # evaporation
#   SKINW = 0.5 # part of the skin surface that is wet (%)
#   FURWET = 0 # part of the fur/feathers that is wet after rain (%)
#   PCTBAREVAP = 0 # surface area for evaporation that is skin, e.g. licking paws (%)
#   PCTEYES = 0 # surface area made up by the eye (%) - make zero if sleeping
#   DELTAR = 0 # offset between air temeprature and breath (°C)
#   RELXIT = 100 # relative humidity of exhaled air, %
#
#   # metabolism/respiration
#   QBASAL = (70 * AMASS ^ 0.75) * (4.185 / (24 * 3.6)) # basal heat generation (W)
#   TIMACT = 1 # multiplier on metabolic rate for activity costs
#   RQ = 0.80 # respiratory quotient (fractional, 0-1)
#   EXTREF = 20 # O2 extraction efficiency (%)
#   PANTMAX = 2 # maximum breathing rate multiplier to simulate panting (-)
#   Q10 = 1 # Q10 factor for adjusting BMR for TC
#
#   # initial conditions
#   TS = TC - 3 # skin temperature (°C)
#   TFA = TA # fur/air interface temperature (°C)
#
#   # other model settings
#   DIFTOL = 0.001 # tolerance for SIMULSOL
  # at this stage make sure NESTYP = 0 to get correct configuration factors
  NESTYP <- 0
  if(PANTING == 0){
    PANTMAX <- PANT # can't pant, so panting level set to current value
  }
  if(SWEAT == 0){
    MXWET <- SKINW # can't sweat, so max maximum skin wetness equal to current value
  }
  if(RAISETC == 0){
    TCMAX <- TC # can't raise Tc, so max value set to current value
  }
  if(AK1inc == 0){
    AKMAX <- AK1 # can't change thermal conductivity, so max value set to current value
  }
  if(UNCURL == 0){
    SHAPE_B_MAX <- SHAPE_B # can't change posture, so max multiplier of dimension set to current value
  }
  QGEN <- 0
  TCREF <- TC
  QBASREF <- QBASAL
  # check if heat stressed already
  if(TA >= TC){
    # set core temperature, flesh thermal conductivity and shape to
    # extreme heat loss values, adjusting basal metabolic
    # rate for temperature increase
    if(TA > TCMAX){
      TC <- TCMAX
      Q10mult <- Q10^((TC - TCREF)/10)
      QBASAL = QBASREF * Q10mult
    }
    AK1 <- AKMAX
    SHAPE_B <- SHAPE_B_MAX
  }
  TVEG <- TA
  SOLVENDO.input <- c(QGEN, QBASAL, TA, SHAPE_B_MAX, SHAPE_B_REF, SHAPE_B, DHAIRD, DHAIRV, LHAIRD, LHAIRV, ZFURD, ZFURV, RHOD, RHOV, REFLD, REFLV, MAXPTVEN, SHAPE, EMISAN, FATOBJ, FSKREF, FGDREF, NESTYP, PCTDIF, ABSSB, SAMODE, FLTYPE, ELEV, BP, NITESHAD, SHADE, QSOLR, RoNEST, Z, VEL, TS, TFA, FABUSH, FURTHRMK, RH, TCONDSB, TBUSH, TC, PCTBAREVAP, FLYHR, FURWET, AK1, AK2, PCTEYES, DIFTOL, SKINW, TSKY, TVEG, TAREF, DELTAR, RQ, TIMACT, O2GAS, N2GAS, CO2GAS, RELXIT, PANT, EXTREF, UNCURL, AKMAX, AK1inc, TCMAX, RAISETC, TCREF, Q10, QBASREF, PANTMAX, MXWET, SWEAT, TGRD, AMASS, ANDENS, SUBQFAT, FATPCT, PCOND, MAXPCOND, ZFURCOMP, PANTING, ORIENT, SHAPE_C)
  if(WRITE_INPUT == 1){
   write.csv(SOLVENDO.input, file = "SOLVENDO.input.csv")
  }
  endo.out <- SOLVENDO(SOLVENDO.input)
  return(endo.out)
}
