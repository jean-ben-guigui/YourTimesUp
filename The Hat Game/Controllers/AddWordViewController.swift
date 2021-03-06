//
//  AddWordViewController.swift
//  Your Time's Up
//
//  Created by Arthur Duver on 16/04/2019.
//  Copyright © 2019 Arthur Duver. All rights reserved.
//

import UIKit
import CoreData

class AddWordViewController: UIViewController {
    
    var hatGame:HatGame?
    var wordToValidate:String = ""
    var wordSet:WordSetEntity?
    
    private lazy var wordEntityProvider: WordEntityProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = WordEntityProvider(with: appDelegate.coreDataStack.persistentContainer,
                                   fetchedResultsControllerDelegate: nil)
        return provider
    }()
    
    private lazy var wordSetEntityProvider: WordSetEntityProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = WordSetEntityProvider(with: appDelegate.coreDataStack.persistentContainer,
                                   fetchedResultsControllerDelegate: nil)
        return provider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let hatGame = hatGame else {
            fatalError("prepareforsegue, Cannot found hatGame in addWordViewcontroller")
        }
        if (segue.identifier == "whosTurnSegue") {
            if let destination = segue.destination as? WhosTurnViewController {
                destination.hatGame = hatGame
            }
        }
    }
    
    @IBOutlet var addWordView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var wordNumberLabel: UILabel!
	@IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var wordInput: UITextField!
    
    /// Handles the validation of a word entered by the user:
    /// - display an alert if the word already exists
    /// - adjust the number /24 and the name of the team that should be entering the next word
    @IBAction func validateWord(_ sender: UIButton) {
        addWord()
    }
	
	@IBAction func wordEdited(_ sender: UITextField) {
        if let word = sender.text  {
            wordToValidate = word
            if word != "" {
                doneButton.isEnabled = true
            } else {
                 doneButton.isEnabled = false
            }
        }
    }
    
	@IBAction func tapOnContainer(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	@IBAction func startNow(_ sender: Any) {
		if let nnHatGame = hatGame {
            if nnHatGame.wordCount() < Constants.minimumNumberOfWordsToPlay {
                let continueAnywayAction = UIAlertAction(title:"Start playing", style: .default, handler: { _ in
                    self.performSegue(withIdentifier: "whosTurnSegue", sender: self)
                    })
				let addMoreWordsAction = UIAlertAction(title:"Add more words", style: .cancel)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    let presenter = AlertPresenter(
                        title: "Hey there",
                        message: Constants.Alert.Message.tooFewWord,
                        completionActions: [continueAnywayAction, addMoreWordsAction]
                    )
                    presenter.present(in: self)
                }
            } else {
                self.performSegue(withIdentifier: "whosTurnSegue", sender: self)
            }
        }
	}
    
    func setTeamNameLabel(teamName:String) {
        teamNameLabel.text = "Team " + teamName + " enters a word"
    }
    
    func saveWord(word: String) {
        guard let wordSet = self.wordSet else {
            return
        }
        let managedContext = wordSet.managedObjectContext!
        
        // 1 Create Word in base
        self.wordEntityProvider.addWordEntity(data: word,
											  wordSet: wordSet,
                                              context: managedContext,
                                              shouldSave: true)
    }
	
	func addWord() {
		guard let hatGame = hatGame else {
            fatalError("validate word: Cannot found hatGame in addWordViewcontroller")
        }
        do {
            try hatGame.addWordToWordSet(wordToValidate)
            saveWord(word: wordToValidate)
        } catch {
            let presenter = AlertPresenter(title: Constants.Alert.Title.trouble.rawValue, message: Constants.Alert.Message.wordAlreadyEntered(word: wordToValidate), completionAction: nil)
            presenter.present(in: self)
        }
        if hatGame.wordSet.words.count > 23 {
            performSegue(withIdentifier: "whosTurnSegue", sender: self)
        }
        else if let wordNumberString = wordNumberLabel.text {
            if var wordNumberInt = Int(wordNumberString) {
                wordNumberInt += 1
                wordNumberLabel.text = String(wordNumberInt)
                do {
                    let teamPlaying = try hatGame.getTeam(id: wordNumberInt % (hatGame.teams.count))
                    setTeamNameLabel(teamName: teamPlaying.name)
                } catch {
					//silent error
                }
            }
        }
        wordInput.text = ""
		doneButton.isEnabled = false
	}
    
    func configure(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let hatGame = self.hatGame else {
                return
            }
			self.wordInput.delegate = self
            self.doneButton.isEnabled = false
			self.doneButton.setTitleColor(UIColor.systemGray2, for: UIControl.State.disabled)
            do {
                let firstTeam = try hatGame.getTeam(id:0)
                self.setTeamNameLabel(teamName: firstTeam.name)
            } catch {
                let presenter = AlertPresenter(
                    title: Constants.Alert.Title.unexpectedError.rawValue,
                    message: "The team that is supposed to enter a word does not exist, try to close the app and launch it again.",
                    completionAction: nil
                )
                presenter.present(in: self)
                return
            }
        }
    }
}

extension AddWordViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		addWord()
		return false
	}
}
