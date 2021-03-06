//
//  AnnotationViewController.swift
//  HackerBooksLite
//
//  Created by Alejandro Moreno Alberto on 30/9/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import MapKit

class AnnotationViewController: UIViewController,  CLLocationManagerDelegate{
    
    private
    var _book: Book
    var _note : Annotation?
    var deleteAnnotation: Bool = false
    
    let locationManager = CLLocationManager()
    var location: Location = Location()

    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleView: UITextField!
    @IBOutlet weak var flexible: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBAction func Map(_ sender: AnyObject) {
        let vc = MapViewController(note: _note)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func takePhoto(_ sender: AnyObject) {
        if _note != nil {
            let vc = PhotoViewController(note: _note!)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let note = Annotation()
            let noteVC = PhotoViewController(note: note)
            self.navigationController?.pushViewController(noteVC, animated: true)
        }
        
        
    }
   
    @IBAction func deleteNote(_ sender: AnyObject) {
        deleteAnnotation = true
        self.navigationController?.popViewController(animated: true)
    }
    
    init(book: Book) {
        _book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(book: Book, note: Annotation){
        self.init(book: book)
        _note = note
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if _note == nil{
            self.title = "New Note"
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AnnotationViewController.cancelNote))
            
            self.navigationItem.rightBarButtonItem = cancelButton
            self.mapButton.isEnabled = false
            self.mapButton.tintColor = UIColor.clear
            self.deleteButton.isEnabled = false
            self.deleteButton.tintColor = UIColor.clear
            
            
        }else{
            self.title = _note?.title
            self.titleView.text = _note?.title
            self.textView.text = _note?.text
            
            let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(AnnotationViewController.shareNote))
            
            self.navigationItem.rightBarButtonItem = shareButton
            
        }
    }
    
    override func viewDidLoad() {
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if !deleteAnnotation {
            if (_note != nil){
                try! Realm().write {
                    _note?.title = titleView.text!
                    _note?.text = textView.text
                    _note?.modificationDate = Date()
                }
            }else{
                try! Realm().write {
                    let newNote = Annotation()
                    newNote.title = titleView.text!
                    newNote.text = textView.text
                    newNote.modificationDate = Date()
                    newNote.location = location
                    try! Realm().add(newNote)
                    _book.notes.append(newNote)
                }
            }
            
        }else{
            try! Realm().write {
                try! Realm().delete(_note!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func cancelNote(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func shareNote() {
        let vc = UIActivityViewController(activityItems: [titleView.text, textView.text], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    //CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        try! Realm().write {
            self.location.latitude = locValue.latitude
            self.location.longitude = locValue.longitude
            try! Realm().add(location)
        }
        
    }
}
