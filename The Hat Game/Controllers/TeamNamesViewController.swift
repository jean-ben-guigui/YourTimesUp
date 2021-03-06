//
//  ViewController.swift
//  Your Time's Up
//
//  Created by Arthur Duver on 10/03/2019.
//  Copyright © 2019 Arthur Duver. All rights reserved.
//

import UIKit
import CoreData

class TeamNamesViewController: UIViewController {
    
    private lazy var wordSetEntityProvider: WordSetEntityProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = WordSetEntityProvider(with: appDelegate.coreDataStack.persistentContainer,
                                   fetchedResultsControllerDelegate: nil)
        return provider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hatGame = HatGame([])
        addTeam(hatGame: hatGame, button: firstTeamName)
        addTeam(hatGame: hatGame, button: secondTeamName)
        addTeam(hatGame: hatGame, button: thirdTeamName)
        addTeam(hatGame: hatGame, button: fourthTeamName)
        if (segue.identifier == "addWordsSegue") {
            if let addWordController = segue.destination as? AddWordViewController {
                addWordController.hatGame = hatGame
                wordSetEntityProvider.addWordSet(in: wordSetEntityProvider.persistentContainer.viewContext, completionHandler: { (wordSetEntity) in
                    addWordController.wordSet = wordSetEntity
                })
            }
        }
        if (segue.identifier == "chooseWordSetSegue") {
            if let wordSetPickerController = segue.destination as? WordSetPickerController {
                wordSetPickerController.hatGame = hatGame
            }
        }
    }
    @IBOutlet private weak var firstTeamName: UITextField!
    @IBOutlet private weak var secondTeamName: UITextField!
    @IBOutlet private weak var thirdTeamName: UITextField!
    @IBOutlet private weak var fourthTeamName: UITextField!
	@IBOutlet private weak var startTheGameButton: UIButton!
	
    
    @IBAction private func firstTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
    @IBAction private func secondTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
    @IBAction private func thirdTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
    @IBAction private func fourthTeamNameEdited(_ sender: UITextField) {
        setGameButtonState()
    }
	@IBAction private func tapOnContainer(_ sender: Any) {
		self.view.endEditing(true)
	}
	
    @IBAction func StartTheGame(_ sender: UIButton) {
        // fetches the WordSet objects from the database.
        if wordSetEntityProvider.areWordSetsNil() {
            self.performSegue(withIdentifier: "addWordsSegue", sender: sender)
        } else {
            let yesAction = UIAlertAction(title: Constants.chooseWordSet.yes.rawValue,
                                          style: .default,
                                          handler: { [unowned self] (alertAction)  in
                self.performSegue(withIdentifier: "chooseWordSetSegue", sender: sender)
            })
            let createNewSetAction = UIAlertAction(title: Constants.chooseWordSet.no.rawValue,
                                                   style: .default,
                                                   handler: { [unowned self] (alertAction) in
                self.performSegue(withIdentifier: "addWordsSegue", sender: sender)
            })
            let cancelAction = UIAlertAction(title: Constants.cancelMessage, style: .cancel, handler: nil)
            let chooseWordSetPresenter = AlertPresenter(title: nil,
                                                        message: Constants.chooseWordSet.title.rawValue,
                                                        completionActions: [yesAction, createNewSetAction, cancelAction])
            chooseWordSetPresenter.present(in: self)
        }
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
                        title: Constants.Alert.Title.trouble.rawValue,
                        message: Constants.Alert.Message.wordAlreadyEntered(word: word),
                        completionAction: nil
                    )
                    presenter.present(in: self)
                } catch {
                    let presenter = AlertPresenter(
                        title: Constants.Alert.Title.trouble.rawValue,
                        message: Constants.Alert.Message.unknow,
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
//        startTheGameButton.makeMyAnglesRound()
        if let placeholderColor = UIColor(named: "placeholderColor") {
            firstTeamName.setPlaceHolderColor(color: placeholderColor)
			firstTeamName.delegate = self
            secondTeamName.setPlaceHolderColor(color: placeholderColor)
			secondTeamName.delegate = self
            thirdTeamName.setPlaceHolderColor(color: placeholderColor)
			thirdTeamName.delegate = self
            fourthTeamName.setPlaceHolderColor(color: placeholderColor)
			fourthTeamName.delegate = self
        }
		firstTeamName.becomeFirstResponder()
        startTheGameButton.setTitleColor(UIColor.systemGray2, for: UIControl.State.disabled)
        setGameButtonState()
    }
}

extension TeamNamesViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
