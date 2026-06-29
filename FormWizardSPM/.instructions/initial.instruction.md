
## General

I want to create a new swift package manager call FormWizardSPM. Support Swift 6.2, use SwiftUI and iOS 26 only. The goal of the framework is for a user to go through a 4 step form before the form can be submitted. The transition between the screens should be vertical. 

### Screens:
 
 - User Information Input
 	- name
 	- address
 	- email
 	- phone number
 - Appliance Type (washer / dryer, fireplace, grill) and comment
 - Photo Selection / Upload (3 photos max)
 - Date / Time selection for repair

All input fields required before the user can proceed to the next screen. Once the user has completed a screen they can go back and modify their inputed information but validation rules still apply.

Use this design as a reference https://www.figma.com/make/SGESfAfxqV3NOU7E3iBCqr/4-Step-Vertical-Form?t=ouWf20OPfuJtoOPZ-20&fullscreen=1