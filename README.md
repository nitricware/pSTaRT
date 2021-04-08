# pSTaRT - pocket Simple Triage and Rapid Treatment

pSTaRT guides the user thru the process of triaging persons during an emergency situation. It uses the mSTaRT questionnaire to classify persons into four different categories as definied i.e. in the Manchester Triage System.

## Process

1. Enter a person identifier or scan a Code39 code (The swiss and austrian PLS uses Code 39)
2. Answer the questionnaire
3. Repeat

## Features

* Triage persons
* PLS code scanner
* person database
* treatment room person counter
* export persons list as CSV

## Author

Kurt Höblinger is developer and ambulance man in austria. Gerald Niedermayer helped by giving valuable input throughout development. Thank you.

## Availability

This software is available on the iOS App Store: https://apps.apple.com/us/app/pstart/id1488221355?l=de

## To-Do
* in better_retriage: save triage as Person.triage = new Triages()
* in better_retriage: display most recent triage group
* in better_retriage: export all changes to triage group
* in better_retriage: when retriaging, save new group as new Triage() 
* in better_retriage: display triage history
