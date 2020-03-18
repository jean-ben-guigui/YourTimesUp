//
//  ViewController.swift
//  Your Time's Up
//
//  Created by Arthur Duver on 10/03/2019.
//  Copyright © 2019 Arthur Duver. All rights reserved.
//

import UIKit

class TeamNamesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hatGame = HatGame([])
        addTeam(hatGame: hatGame, button: firstTeamName)
        addTeam(hatGame: hatGame, button: secondTeamName)
        addTeam(hatGame: hatGame, button: thirdTeamName)
        addTeam(hatGame: hatGame, button: fourthTeamName)
        // TODO maybe check that there is not 2 teams sharing a same name (nouvelle méthode pour Teams). Since we check it when the startTheGameButton is pressed, no real needs to do so though.
        if (segue.identifier == "addWordsSegue") {
            if let addWordController = segue.destination as? AddWordViewController {
                addWordController.hatGame = hatGame
            }
        }
    }
    @IBOutlet weak var firstTeamName: UITextField!
    @IBOutlet weak var secondTeamName: UITextField!
    @IBOutlet weak var thirdTeamName: UITextField!
    @IBOutlet weak var fourthTeamName: UITextField!
    
    @IBOutlet weak var startTheGameButton: UIButton!
    @IBAction func firstTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
    @IBAction func secondTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
    @IBAction func thirdTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
    @IBAction func fourthTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
    
    @IBAction func StartTheGame(_ sender: UIButton) {
        performSegue(withIdentifier: "addWordsSegue", sender: sender)
    }
    
    func areTeamNamesEmpty() -> Bool {
        if firstTeamName.text != "" ||
            secondTeamName.text != "" ||
            thirdTeamName.text != "" ||
            fourthTeamName.text != "" {
            return false
        }
        return true
    }
    
    func areThereTwoTeamsName() -> Bool {
        let teamNames = [firstTeamName.text, secondTeamName.text, thirdTeamName.text, fourthTeamName.text]
        var teamCount = 0
        for teamName in teamNames {
            if teamName != "" {
                teamCount += 1
                if teamCount > 1 {
                    return true
                }
            }
        }
        return false
    }
    
    func addTeam(hatGame:HatGame, button:UITextField) {
        if let teamName = button.text {
            if teamName != "" {
                do {
                    try hatGame.addTeam(name: teamName)
                } catch WordSetError.wordAlreadyInSet(let word) {
                    let presenter = AlertPresenter(
                        title: Constants.troubleAlertTitle,
                        message: Constants.wordAlreadyEntered(word: word),
                        completionAction: nil
                    )
                    presenter.present(in: self)
                } catch {
                    let presenter = AlertPresenter(
                        title: Constants.troubleAlertTitle,
                        message: Constants.unknowErrorMessage,
                        completionAction: nil
                    )
                    presenter.present(in: self)
                }
            }
        }
    }
    
    func setGameButtonState() {
        startTheGameButton.isEnabled = areThereTwoTeamsName()
    }
    
    func configure() {
        startTheGameButton.makeMyAnglesRound()
        startTheGameButton.setTitleColor(UIColor.lightGray, for: UIControl.State.disabled)
        setGameButtonState()
    }
}
