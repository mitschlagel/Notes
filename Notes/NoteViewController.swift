//
//  NoteViewController.swift
//  Notes
//
//  Created by Spencer Jones on 1/16/24.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {
    var note: Note!
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = note.contents
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        note.contents = textView.text
        NoteManager.shared.save(note: note)
    }
}
