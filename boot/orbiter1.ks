function getSpeed {
    parameter gravitationalParam.
    parameter planetRadius.
    parameter targetAltitude.
    parameter apoap.
    parameter periap. 

    return sqrt(gravitationalParam * (2/(planetRadius+targetAltitude) - 1/((apoap+periap)/2+planetRadius)) ) .
}

clearscreen.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

print "Waiting for ship to unpack.".
wait until ship:unpacked.
print "Ship is now unpacked.".

PRINT "Counting down:".
FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

print "Launching".
lock throttle to 0.0.
set _heading to 90.
lock steering to heading(0,_heading).
stage.

when SHIP:MAXTHRUST = 0 then {
  print "Uncoupling boosters".
  wait 0.2.
  lock throttle to 0.5.
  stage.
}

wait until ship:velocity:surface:mag >= 90.

print "Starting rotation".

set startAngle to 85.
set targetOrbit to 80000.

UNTIL SHIP:ORBIT:APOAPSIS > targetOrbit*1.002 {
    set _heading to startAngle-(ship:orbit:apoapsis/(targetOrbit*1.15))*startAngle.
    print "Angle : " at (0,12).
    print round(_heading) at (8,12).
}.

lock throttle to 0.0.
print "waiting for apoapsis".

wait until ship:altitude > 75000.

set apoapsisSpeed to getSpeed(kerbin:mu, kerbin:radius, ship:orbit:apoapsis, ship:orbit:apoapsis, ship:orbit:periapsis).
set targetSpeed to getspeed(kerbin:mu, kerbin:radius, ship:orbit:apoapsis, ship:orbit:apoapsis, ship:orbit:apoapsis).

set manoeuver to node(time:seconds+eta:apoapsis, 0, 0, targetSpeed-apoapsisSpeed).
add manoeuver.

lock steering to manoeuver:burnvector.
set max_acc to ship:maxthrust/ship:mass.
set burnDuration to manoeuver:deltav:mag/max_acc.

wait until manoeuver:eta < 0.5*burnDuration.

lock throttle to 1.0.
wait until manoeuver:deltav:mag < 0.1.
lock throttle to 0.0.

SAS ON.
print "Welcome to space".