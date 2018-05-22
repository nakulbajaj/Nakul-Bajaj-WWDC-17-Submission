//: Playground - noun: a place where people can play

import Foundation
import UIKit
import SceneKit
import QuartzCore
import AVFoundation
import PlaygroundSupport

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var sceneView: SCNView!
    var navigationBar: UINavigationBar!
    var detailView: UIView!
    var effectBlur: UIVisualEffect!
    var effectVibrancy: UIVisualEffect!
    var blurredEffectView: UIVisualEffectView!
    var vibrancyEffectView: UIVisualEffectView!
    var firstDetailView: UIView!
    var secondDetailView: UIView!
    var thirdDetailView: UIView!
    var flippedDetailView: UIView!
    var sideSelectedCurrently: String!
    var detailSelectedCurrently: Int!
    var tapOutsideDetailTransparentButton: UIButton!
    var tapInDetailGesture: UITapGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    var faceTappedPath = Bundle.main.url(forResource: "faceTappedSoundEffect", withExtension: "m4a")
    var viewDismissedPath = Bundle.main.url(forResource: "viewDismissed", withExtension: "m4a")
    var faceTappedPlayer: AVAudioPlayer!
    var viewDismissedPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        //Remove from Superviews - good for allowing sizing issues to go away
        //        sceneView?.removeFromSuperview()
        //        navigationBar?.removeFromSuperview()
        //        detailView?.removeFromSuperview()
        //        firstDetailView?.removeFromSuperview()
        //        secondDetailView?.removeFromSuperview()
        //        thirdDetailView?.removeFromSuperview()
        
        //Set up Navigation Bar
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:44))
        navigationBar.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha: 1.0)
        let navigationItem = UINavigationItem()
        navigationItem.title = "Nakul Bajaj"
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        //Main view BG Color Set
        self.view.backgroundColor = UIColor.white
        
        //Set up blurring and vibrancy
        let blurEffect = UIBlurEffect(style: .light)
        blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.view.bounds
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = self.view.bounds
        
        //Creating a new detail view
        detailView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width*3/4, height: self.view.bounds.height/2))
        detailView.layer.cornerRadius = 10.0
        
        //The rest is setting up the 3D cube..
        
        //Setting up SCNView
        sceneView = SCNView(frame: CGRect(x: 0, y: 44, width: self.view.bounds.width, height: self.view.bounds.height - 100))
        self.view.addSubview(sceneView)
        
        let scene = SCNScene()
        
        //Camera and SCNBox
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 25)
        scene.rootNode.addChildNode(cameraNode)
        let boxGeometry = SCNBox(width: 9, height: 9, length: 9, chamferRadius: 0.5)
        let boxNode = SCNNode(geometry: boxGeometry)
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
        
        //Enable lighting and control
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        //Create cube face materials and build
        let top = SCNMaterial()
        let bottom = SCNMaterial()
        let left = SCNMaterial()
        let right = SCNMaterial()
        let front = SCNMaterial()
        let back = SCNMaterial()
        
        top.diffuse.contents = UIImage(named: "Projects Icon")
        top.locksAmbientWithDiffuse = true;
        
        bottom.diffuse.contents = UIImage(named: "Future Icon")
        bottom.locksAmbientWithDiffuse = true;
        
        left.diffuse.contents = UIImage(named: "Programming Icon")
        left.locksAmbientWithDiffuse = true;
        
        right.diffuse.contents = UIImage(named: "Debate Icon")
        right.locksAmbientWithDiffuse = true;
        
        front.diffuse.contents = UIImage(named: "About Me Icon")
        front.locksAmbientWithDiffuse = true;
        
        back.diffuse.contents = UIImage(named: "Water Polo Icon")
        back.locksAmbientWithDiffuse = true;
        
        boxGeometry.materials = [ front, right, back, left, top, bottom ]
        
        //Effect additions and management
        sceneView.addSubview(blurredEffectView)
        sceneView.addSubview(vibrancyEffectView)
        effectBlur = blurredEffectView.effect
        effectVibrancy = vibrancyEffectView.effect
        blurredEffectView.effect = nil
        vibrancyEffectView.effect = nil
        
        //Add tapgesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedFace(_:)))
        self.sceneView!.addGestureRecognizer(tapGesture)
    }
    
    //This method occurs to recognize which face was tapped
    func tappedFace(_ sender: UITapGestureRecognizer) {
        
        //Tap in SCNView has happened - debugging
        //Get point where tapped
        let p = sender.location(in: sceneView)
        //hitTest
        guard let hitResults = sceneView.hitTest(p, options: nil) as? [SCNHitTestResult] else { return }
        //Check hitTest and sense side
        if let result = hitResults.first {
            //let node = result.node
            //let material = node.geometry!.materials[result.geometryIndex]
            
            enum CubeFace: Int {
                case Front, Right, Back, Left, Top, Bottom
            }
            let tappedSideString = (String(describing: CubeFace(rawValue: result.geometryIndex)))
            
            //Check the side selected, translate it to the hobby/activity and make it globally available
            //Create the detailView which will pop up
            if (tappedSideString.range(of: "Front") != nil) {
                let sideStringInternal = "About Me"
                sideSelectedCurrently = sideStringInternal
                customizeDetailView(side: sideStringInternal)
            }
            else if (tappedSideString.range(of: "Right") != nil) {
                let sideStringInternal = "Debate"
                sideSelectedCurrently = sideStringInternal
                customizeDetailView(side: sideStringInternal)
            }
            else if (tappedSideString.range(of: "Back") != nil) {
                let sideStringInternal = "Water Polo"
                sideSelectedCurrently = sideStringInternal
                customizeDetailView(side: sideStringInternal)
            }
            else if (tappedSideString.range(of: "Left") != nil) {
                let sideStringInternal = "Programming"
                sideSelectedCurrently = sideStringInternal
                customizeDetailView(side: sideStringInternal)
            }
            else if (tappedSideString.range(of: "Top") != nil) {
                let sideStringInternal = "Projects"
                sideSelectedCurrently = sideStringInternal
                customizeDetailView(side: sideStringInternal)
            }
            else if (tappedSideString.range(of: "Bottom") != nil) {
                let sideStringInternal = "Future"
                sideSelectedCurrently = sideStringInternal
                customizeDetailView(side: sideStringInternal)
            }
        }
        
    }
    
    //Customize the detail View with the color, etc.
    func customizeDetailView(side: String){
        do {
            faceTappedPlayer = try AVAudioPlayer(contentsOf: faceTappedPath!)
            guard let faceTappedPlayer = faceTappedPlayer else { return }
            faceTappedPlayer.prepareToPlay()
            faceTappedPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
        //Make a header for the interest
        var headerSide: UILabel!
        headerSide?.removeFromSuperview()
        headerSide = UILabel(frame: CGRect(x: 0, y: 0, width: self.detailView.bounds.width, height: 60))
        headerSide.center = CGPoint(x: self.detailView.bounds.width/2, y: 30)
        headerSide.text = side
        headerSide.font = UIFont(name: "AppleSDGothicNeo", size: 40)
        headerSide.textAlignment = .center
        detailView.addSubview(headerSide)
        
        //I want exactly three sections per interest/side on cube
        firstDetailView = UIView()
        secondDetailView = UIView()
        thirdDetailView = UIView()
        //I "precustomize" those views
        preCustomizeDetailViews(specialDetailView: firstDetailView, orderNumber: 1)
        preCustomizeDetailViews(specialDetailView: secondDetailView, orderNumber: 2)
        preCustomizeDetailViews(specialDetailView: thirdDetailView, orderNumber: 3)
        //Then I make any label/image additions to the main detail view depending on the interest
        if side == "About Me" {
            detailView.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
            addElementsToDetailSection(sectionDetailView: firstDetailView, imageName: "Quick Facts", sectionName: "Quick Facts")
            addElementsToDetailSection(sectionDetailView: secondDetailView, imageName: "Experiences", sectionName: "Experiences")
            addElementsToDetailSection(sectionDetailView: thirdDetailView, imageName: "My Schedule", sectionName: "My Schedule")
        }
        else if side == "Debate" {
            detailView.backgroundColor = UIColor(red:0.83, green:0.31, blue:0.29, alpha:1.0)
            addElementsToDetailSection(sectionDetailView: firstDetailView, imageName: "Setup", sectionName: "Background")
            addElementsToDetailSection(sectionDetailView: secondDetailView, imageName: "Importance", sectionName: "Importance")
            addElementsToDetailSection(sectionDetailView: thirdDetailView, imageName: "Awards", sectionName: "Awards")
        }
        else if side == "Water Polo" {
            detailView.backgroundColor = UIColor(red:0.37, green:0.70, blue:0.89, alpha:1.0)
            addElementsToDetailSection(sectionDetailView: firstDetailView, imageName: "Rules", sectionName: "Rules")
            addElementsToDetailSection(sectionDetailView: secondDetailView, imageName: "Determination", sectionName: "Determination")
            addElementsToDetailSection(sectionDetailView: thirdDetailView, imageName: "Loving Water", sectionName: "Loving Water")
        }
        else if side == "Programming" {
            detailView.backgroundColor = UIColor(red:0.92, green:0.44, blue:0.44, alpha:1.0)
            addElementsToDetailSection(sectionDetailView: firstDetailView, imageName: "Choosing iOS", sectionName: "Choosing iOS")
            addElementsToDetailSection(sectionDetailView: secondDetailView, imageName: "Importance", sectionName: "Importance")
            addElementsToDetailSection(sectionDetailView: thirdDetailView, imageName: "Improving", sectionName: "Improving")
        }
        else if side == "Projects" {
            detailView.backgroundColor = UIColor(red:0.95, green:0.80, blue:0.36, alpha:1.0)
            addElementsToDetailSection(sectionDetailView: firstDetailView, imageName: "Win2Give", sectionName: "Win2Give")
            addElementsToDetailSection(sectionDetailView: secondDetailView, imageName: "Mitosis Stages", sectionName: "Mitosis Stages")
            addElementsToDetailSection(sectionDetailView: thirdDetailView, imageName: "Tower Defriendz", sectionName: "Tower Defriendz")
        }
        else if side == "Future" {
            detailView.backgroundColor = UIColor(red:0.63, green:0.80, blue:0.24, alpha:1.0)
            addElementsToDetailSection(sectionDetailView: firstDetailView, imageName: "High School", sectionName: "High School")
            addElementsToDetailSection(sectionDetailView: secondDetailView, imageName: "Using Technology", sectionName: "Using Technology")
            addElementsToDetailSection(sectionDetailView: thirdDetailView, imageName: "Community", sectionName: "Community")
        }
        //add as subviews
        detailView.addSubview(firstDetailView)
        detailView.addSubview(secondDetailView)
        detailView.addSubview(thirdDetailView)
        
        animateIn()
    }
    func addElementsToDetailSection(sectionDetailView: UIView, imageName: String?, sectionName: String){
        let sectionLabel = UILabel(frame: CGRect(x: 10, y: 0, width: sectionDetailView.bounds.width*3/4, height: 40))
        sectionLabel.center = CGPoint(x: sectionLabel.center.x, y: sectionDetailView.bounds.height/2)
        sectionLabel.textAlignment = .left
        sectionLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 22)
        sectionLabel.text = sectionName
        sectionDetailView.addSubview(sectionLabel)
        if imageName != nil {
            let sectionImage = UIImage(named: imageName!)
            let dimensionRatio = (sectionImage?.size.width)!/(sectionImage?.size.height)!
            let sectionImageView = UIImageView(image: sectionImage)
            let presetHeight = sectionDetailView.bounds.height - 10
            let presetWidth = presetHeight*dimensionRatio
            sectionImageView.frame = CGRect(x: sectionDetailView.bounds.width - presetWidth - 5, y: 5, width: presetWidth, height: presetHeight)
            sectionDetailView.addSubview(sectionImageView)
        }
        
    }
    func preCustomizeDetailViews(specialDetailView: UIView, orderNumber: Int){
        
        let remainingHeightSpaceDetailView = detailView.bounds.height - 65
        let remainingWidthSpaceDetailView = detailView.bounds.width - 20
        let detailHeight = remainingHeightSpaceDetailView/3 - 5
        
        specialDetailView.frame = CGRect(x: 0, y: 0, width: remainingWidthSpaceDetailView, height: detailHeight)
        specialDetailView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        specialDetailView.layer.borderColor = UIColor.black.cgColor
        specialDetailView.layer.cornerRadius = 10.0
        specialDetailView.layer.borderWidth = 2.0
        
        if orderNumber == 1 {
            let tapInFirstDetailGesture = UITapGestureRecognizer(target: self, action: #selector(self.firstFlipDetailView))
            specialDetailView.addGestureRecognizer(tapInFirstDetailGesture)
            specialDetailView.center = CGPoint(x: self.detailView.bounds.width/2, y: remainingHeightSpaceDetailView/6 + 60)
        }
        else if orderNumber == 2 {
            let tapInSecondDetailGesture = UITapGestureRecognizer(target: self, action: #selector(self.secondFlipDetailView))
            specialDetailView.addGestureRecognizer(tapInSecondDetailGesture)
            specialDetailView.center = CGPoint(x: self.detailView.bounds.width/2, y: remainingHeightSpaceDetailView/2 + 60)
        }
        else if orderNumber == 3{
            let tapInThirdDetailGesture = UITapGestureRecognizer(target: self, action: #selector(self.thirdFlipDetailView))
            specialDetailView.addGestureRecognizer(tapInThirdDetailGesture)
            specialDetailView.center = CGPoint(x: self.detailView.bounds.width/2, y: remainingHeightSpaceDetailView*5/6 + 60)
        }
        
    }
    
    func firstFlipDetailView(){
        detailSelectedCurrently = 1
        flipDetailView()
    }
    func secondFlipDetailView(){
        detailSelectedCurrently = 2
        flipDetailView()
    }
    func thirdFlipDetailView(){
        detailSelectedCurrently = 3
        flipDetailView()
    }
    func flipDetailView(){
        do {
            faceTappedPlayer = try AVAudioPlayer(contentsOf: faceTappedPath!)
            guard let faceTappedPlayer = faceTappedPlayer else { return }
            faceTappedPlayer.prepareToPlay()
            faceTappedPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
        matchFlippedDetailWithDetail()
        if sideSelectedCurrently == "About Me" {
            if detailSelectedCurrently == 1 {
                addMainContentLabel(contentString: "I'm Nakul, a 14 year old student at The Harker Upper School. I was born in Ann Arbor, Michigan on June 3rd, 2002, and love making iOS apps. I live in Cupertino with my younger sister. I also ❤️ WWDC17!", imagesExist: true)
                addMainContentImage(imageString: "personal profile")
            }
            if detailSelectedCurrently == 2 {
                addMainContentLabel(contentString: "Experiences define who we are. As Albert Einstein had mentioned, “The only source of knowledge is experience.” \n\nOne of the experiences I had was relocating throughout the US. I moved seven times from places such as Michigan, Missouri, and India while I saw different perspectives from others in those regions. It truly is an experience I am grateful for.", imagesExist: false)
            }
            if detailSelectedCurrently == 3{
                addMainContentLabel(contentString: "During the weekdays, I go to classes at school for 7 hours. Later, I finish my homework, code, work on debate, or attend water polo practice. During the weekends, I finish my homework and spend time with my family.", imagesExist: true)
                addMainContentImage(imageString: "homework.JPG")
            }
        }
        else if sideSelectedCurrently == "Debate" {
            if detailSelectedCurrently == 1 {
                addMainContentLabel(contentString: "Debate is now an international activity that many students participate in. Currently, I focus on Congressional debate, which asks students to act as a US Senator. We usually debate current political proposals.", imagesExist: true)
                addMainContentImage(imageString: "speaking.JPG")
            }
            if detailSelectedCurrently == 2 {
                addMainContentLabel(contentString: "More than just encouraging political participation, debate is useful for learning how to analyze real world problems, speak persuasively with others, and talk fluently in presentations. Speech and debate has been a practical endeavor for many successful people, including Nelson Mandela and Malcom X.", imagesExist: false)
            }
            if detailSelectedCurrently == 3 {
                addMainContentLabel(contentString: "As part of debate, I have been ranked as part of the top 16 middle school teams nationally and was awarded as the top speaker of the California state tournament.", imagesExist: true)
                addMainContentImage(imageString: "first trophy.JPG")
            }
        }
        else if sideSelectedCurrently == "Water Polo" {
            if detailSelectedCurrently == 1 {
                addMainContentLabel(contentString: "Water polo is a sport that is played in a pool with two teams. Each team must score with the ball as many times as possible before the game ends. There are six players from each team in addition to one goalkeeper. In water polo, players cannot touch the floor of the pool, handle the ball with two hands, or unnecessarily hurt other players. Goggles are not permitted.", imagesExist: false)
            }
            if detailSelectedCurrently == 2 {
                addMainContentLabel(contentString: "Water polo’s harsh rules and uncalled fouls shape the sport so the players that are most determined win a game. Playing the sport has shown me why determination is required for personal success.", imagesExist: true)
                addMainContentImage(imageString: "wapo referee.jpg")
            }
            if detailSelectedCurrently == 3 {
                addMainContentLabel(contentString: "Water polo serves as a refresher to calm myself after a long or busy day. Often, I enjoy swimming underwater the most as I almost explore a different type of world that remains serene.", imagesExist: true)
                addMainContentImage(imageString: "wapo underwater.jpg")
            }
        }
        else if sideSelectedCurrently == "Programming" {
            if detailSelectedCurrently == 1 {
                addMainContentLabel(contentString: "Since the start, I have chosen iOS as a platform to develop on because of its ease of use. In fact, I still remember how simple iOS was for me to explore when I was just six years old. The design language and popularity make it an attractive platform. My inspiration today comes from Steve Jobs’ work in making an intuitive operating system.", imagesExist: false)
            }
            if detailSelectedCurrently == 2 {
                addMainContentLabel(contentString: "Programming is important to me because I love seeing my own creations become accessible to almost everyone. I also recognize the benefit it brings for the people that use apps to their full extent.", imagesExist: true)
                addMainContentImage(imageString: "working on coding.JPG")
            }
            if detailSelectedCurrently == 3{
                addMainContentLabel(contentString: "I only started learning true iOS development concepts around the age of eleven. Since then, I have been able to improve massively by learning about more frameworks and APIs. I hope to continue on this path.", imagesExist: true)
                addMainContentImage(imageString: "frameworks")
            }
        }
        else if sideSelectedCurrently == "Projects" {
            if detailSelectedCurrently == 1 {
                addMainContentLabel(contentString: "Win2Give is an app I built which has users quickly solve math problems, while donating a cent to charity for every question they get correct. By using advertising networks, I am able to donate real money to charities.", imagesExist: true)
                addMainContentImage(imageString: "receiveHand")
            }
            if detailSelectedCurrently == 2 {
                addMainContentLabel(contentString: "Mitosis Stages was an app I submitted as a science project for describing the phases that a cell goes through when dividing itself. Videos, images, and animations let my app serve as an interactive textbook.", imagesExist: true)
                addMainContentImage(imageString: "Mitosis Stages")
            }
            if detailSelectedCurrently == 3 {
                addMainContentLabel(contentString: "Tower Defriendz is an iMessage app that was a form of a tower defense game. A player’s goal is to setup their base with as many cannons as they can and defeat any intruding soldiers that might arrive.", imagesExist: true)
                addMainContentImage(imageString: "soldier")
            }
        }
        else if sideSelectedCurrently == "Future" {
            if detailSelectedCurrently == 1 {
                addMainContentLabel(contentString: "For my upcoming years in high school, I plan to take more of the courses that are available to me in computer science, entrepreneurship, and design. To make a software company, it’s important to take advantage of these fields as much as possible. Taking such classes will be helpful for me to assist users, increase revenues, and market products.", imagesExist: false)
            }
            if detailSelectedCurrently == 2 {
                addMainContentLabel(contentString: "In the future, I see myself learning more about deep learning to make predictions and automate services to a greater extent. Also, I will develop more useful apps for wearable technologies.", imagesExist: true)
                addMainContentImage(imageString: "deep learning.jpg")
            }
            if detailSelectedCurrently == 3 {
                addMainContentLabel(contentString: "I personally believe one to one representation and voter participation are characteristics our current governmental system lacks. Addressing these problems is an interest I have right now.", imagesExist: true)
                addMainContentImage(imageString: "vote here")
            }
        }
        let doneImage = UIImage(named: "doneButton")
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: flippedDetailView.bounds.width/7, height: flippedDetailView.bounds.width/7))
        backButton.setImage(doneImage, for: .normal)
        backButton.center = CGPoint(x: flippedDetailView.bounds.width/2, y: flippedDetailView.bounds.height*9/10 - 10)
        backButton.addTarget(self, action: #selector(self.backTapped), for: .touchUpInside)
        flippedDetailView.addSubview(backButton)
        sceneView.addSubview(flippedDetailView)
        flipDetailAnimation()
    }
    func addMainContentImage(imageString: String){
        let profileImage = UIImage(named: imageString)
        let widthHeightRatio = (profileImage?.size.width)!/(profileImage?.size.height)!
        let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: widthHeightRatio * (flippedDetailView.bounds.height/3-10), height: flippedDetailView.bounds.height/3-10))
        profileImageView.center = CGPoint(x: flippedDetailView.bounds.width/2, y: flippedDetailView.bounds.height/6 + 5)
        profileImageView.image = profileImage
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.layer.masksToBounds = true
        flippedDetailView.addSubview(profileImageView)
    }
    func addMainContentLabel(contentString: String, imagesExist: Bool){
        let imageSpaceHeight = flippedDetailView.bounds.height*1/3
        let mainContentLabel = UILabel()
        if imagesExist {
            mainContentLabel.frame = CGRect(x: 20, y: imageSpaceHeight, width: flippedDetailView.bounds.width - 40, height: flippedDetailView.bounds.height - flippedDetailView.bounds.width/7 - imageSpaceHeight - 40)
        }
        else {
            mainContentLabel.frame = CGRect(x: 20, y: 20, width: flippedDetailView.bounds.width - 40, height: flippedDetailView.bounds.height - flippedDetailView.bounds.width/7 - 40)
        }
        mainContentLabel.text = contentString
        mainContentLabel.numberOfLines = 0
        mainContentLabel.font = UIFont(name: "AppleSDGothicNeo", size: 40)
        mainContentLabel.adjustsFontSizeToFitWidth = true
        mainContentLabel.adjustsFontForContentSizeCategory = true
        mainContentLabel.allowsDefaultTighteningForTruncation = true
        mainContentLabel.minimumScaleFactor = 0.1
        flippedDetailView.addSubview(mainContentLabel)
    }
    
    //Quick animation block, used in prev. function
    func flipDetailAnimation(){
        UIView.transition(from: detailView, to: flippedDetailView, duration: 1.0, options: .transitionFlipFromTop, completion: nil)
        
    }
    //Just matches the selected section's flipped view with the detail view background color
    func matchFlippedDetailWithDetail(){
        flippedDetailView = UIView(frame: detailView.frame)
        flippedDetailView.backgroundColor = detailView.backgroundColor
        flippedDetailView.layer.cornerRadius = detailView.layer.cornerRadius
    }
    //animating the detailView in
    func animateIn(){
        sceneView.addSubview(detailView)
        detailView.center = self.view.center
        detailView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        detailView.alpha = 0
        tapOutsideDetailTransparentButton = UIButton(frame: sceneView.bounds)
        tapOutsideDetailTransparentButton.backgroundColor = UIColor.clear
        sceneView.insertSubview(tapOutsideDetailTransparentButton, belowSubview: detailView)
        tapOutsideDetailTransparentButton.addTarget(self, action: #selector(animateOut), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.blurredEffectView.effect = self.effectBlur
            self.vibrancyEffectView.effect = self.effectVibrancy
            self.detailView.alpha = 1
            self.detailView.transform = CGAffineTransform.identity
        })
    }
    func backTapped(){
        do {
            faceTappedPlayer = try AVAudioPlayer(contentsOf: faceTappedPath!)
            guard let faceTappedPlayer = faceTappedPlayer else { return }
            faceTappedPlayer.prepareToPlay()
            faceTappedPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
        self.flippedDetailView?.subviews.forEach {subview in
            subview.removeFromSuperview()
        }
        UIView.transition(from: flippedDetailView, to: detailView, duration: 1.0, options: .transitionFlipFromBottom, completion: nil)
    }
    func animateOut(){
        UIView.animate(withDuration: 0.3, animations: {
            do {
                self.viewDismissedPlayer = try AVAudioPlayer(contentsOf: self.viewDismissedPath!)
                guard let viewDismissedPlayer = self.viewDismissedPlayer else { return }
                viewDismissedPlayer.prepareToPlay()
                viewDismissedPlayer.play()
            } catch let error as NSError {
                print(error.description)
            }
            self.detailView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.detailView.alpha = 0
            self.flippedDetailView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.flippedDetailView?.alpha = 0
            self.blurredEffectView.effect = nil
            self.vibrancyEffectView.effect = nil
        }) { (success:Bool) in
            self.detailView.subviews.forEach {subview in
                subview.removeFromSuperview()
            }
            self.flippedDetailView?.subviews.forEach {subview in
                subview.removeFromSuperview()
            }
            self.firstDetailView.subviews.forEach {subview in
                subview.removeFromSuperview()
            }
            self.secondDetailView.subviews.forEach {subview in
                subview.removeFromSuperview()
            }
            self.thirdDetailView.subviews.forEach {subview in
                subview.removeFromSuperview()
            }
            self.detailView.removeFromSuperview()
            self.flippedDetailView?.removeFromSuperview()
            self.view.addSubview(self.sceneView)
            self.tapOutsideDetailTransparentButton.removeTarget(self, action: #selector(self.animateOut), for: .touchUpInside)
            self.tapOutsideDetailTransparentButton.alpha = 1
            self.tapOutsideDetailTransparentButton.isEnabled = false
            self.tapOutsideDetailTransparentButton = nil
        }
    }
}

//Execution/Compilation/Building/Presenting
let vc = HomeViewController()
PlaygroundPage.current.liveView = vc
PlaygroundPage.current.needsIndefiniteExecution = true

