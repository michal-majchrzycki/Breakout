import UIKit

enum GameStatus {
    case GameOver, YouWon
    
    var image: UIImage? {
        switch self {
        case .GameOver:
            return UIImage(named: "game-over")
        case .YouWon:
            return UIImage(named: "you-won")
        }
    }
}

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet var movePaddleGesture: UIPanGestureRecognizer!
    @IBOutlet var pushBallGesture: UITapGestureRecognizer!
    
//    private lazy var animator: UIDynamicAnimator = {
//        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
//        lazilyCreatedDynamicAnimator.delegate = self
//        
//        #if DEBUG
//            lazilyCreatedDynamicAnimator.debugEnabled = true
//        #endif
//        
//        return lazilyCreatedDynamicAnimator
//    }()
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        #if DEBUG
            print("dynamicAnimatorDidPause")
        #endif
    }
    
    private let breakoutPhysics = BrekoutPhysics()
    
    struct BoundaryNames {
        static let GameViewLeftBoundary = "Game View Left Boundary"
        static let GameViewTopBoundary = "Game View Top Boundary"
        static let GameViewRightBoundary = "Game View Right Boundary"
        static let PaddleBoundary = "Paddle Boundary"
        static let BrickBoundary = "Brick Boundary"
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        animator.addBehavior(breakoutPhysics)
        breakoutPhysics.collidor.collisionDelegate = self
        breakoutPhysics.collidor.action = { [unowned self] in
            if self.startGameButton.hidden == true {
                
                // when ball has left the game (gameView boundaries)
                for ball in self.balls {
                    if !CGRectIntersectsRect(ball.frame, self.gameView.frame) { self.removeBall(ball) }
                }
                
                for specialPower in self.specialBrickPowersCurrentlyDropping {
                    // the frame is moved instantenouly during animation, so the only way to detect
                    // an actual interesect is to use the view's layer.presentationLayer frame
                    
                    if let presentationLayerFrame = specialPower.layer.presentationLayer()?.frame, paddle = self.paddle {
                        if CGRectIntersectsRect(paddle.frame, presentationLayerFrame) {
                            
                            if let brickType = specialPower.brickType {
                                switch brickType {
                                case .LargerPaddle:
                                    paddle.increaseWidth()
                                case .SmallerPaddle:
                                    paddle.decreaseWidth()
                                case .AddBall:
                                    self.createBall()
                                default: break
                                }
                            }
                            specialPower.removeFromSuperview()
                        }
                    }
                }
                
                // Required Tasks
                // 4. When all the bricks have been eliminated (or the game is otherwise over),
                // put up an alert and then reset the bricks for the next game.
                
                if self.balls.count == 0 && self.frozenBalls == nil {
                    self.removeAllSpecialBrickPowersDropping()
                    self.gameOver(GameStatus.GameOver)
                }
                
                if self.balls.count > 0 && self.bricks.count == 0 {
                    self.removeAllBalls()
                    self.removeAllSpecialBrickPowersDropping()
                    self.gameOver(GameStatus.YouWon)
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(BreakoutViewController.settingsDidUpdate),
                                                         name: "BreakoutViewControllerUpdateSettings",
                                                         object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if frozenBalls != nil {
            startGameButton.hidden = true
            restoreBalls()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if !balls.isEmpty {
            freezeBalls()
            removeAllBalls()
        }
    }
    
    // MARK: - Settings were updated
    func settingsDidUpdate() {
        // The value in this property is tied to the value in the
        // gravityDirection property, so changes in one affect the other.
        breakoutPhysics.gravity.magnitude = UserSettings.sharedInstance.gravity
        
        // The default value of this property is the vector (0.0, 1.0),
        // which represents a downward force in the reference view.
        breakoutPhysics.gravity.gravityDirection = CGVector(dx: 0.0, dy: UserSettings.sharedInstance.gravity * 0.5)
        
        breakoutPhysics.ballBehavior.elasticity = UserSettings.sharedInstance.elasticity
    }
    
    // MARK: - Gestures
    
//    @IBOutlet weak var startImageView: UIImageView!
    
    @IBAction func startGame(sender: UIButton) {
        startGameButton.hidden = true
        
        gameView.userInteractionEnabled = true
        pushBallGesture.enabled = true
        movePaddleGesture.enabled = true
        
        createPaddle()
        createBricks()
        addGameViewBoundary()
        createBall()
    }
    
    private func gameOver(status: GameStatus) {
        gameView.userInteractionEnabled = false
        movePaddleGesture.enabled = false
        pushBallGesture.enabled = false
        
        startGameButton.hidden = false
//        startImageView.image = status.image
        
        removePaddle()
        removeAllBricks()
    }
    
    // MARK: - Game view
    
    private func addGameViewBoundary() {
        let gameViewPathLeft = UIBezierPath()
        gameViewPathLeft.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.size.height))
        gameViewPathLeft.addLineToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        
        let gameViewPathTop = UIBezierPath()
        gameViewPathTop.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        gameViewPathTop.addLineToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.origin.y))
        
        let gameViewPathRight = UIBezierPath()
        gameViewPathRight.moveToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.origin.y))
        gameViewPathRight.addLineToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.size.height))
        
        breakoutPhysics.addBoundary(gameViewPathLeft, named: BoundaryNames.GameViewLeftBoundary)
        breakoutPhysics.addBoundary(gameViewPathTop, named: BoundaryNames.GameViewTopBoundary)
        breakoutPhysics.addBoundary(gameViewPathRight, named: BoundaryNames.GameViewRightBoundary)
    }
    
    // MARK: - Collision behavior delegate
    
    // Hints
    // 13. You will find out about collisions between the bouncing ball and brick
    // boundaries with the UICollisionBehavior’s collisionDelegate.
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
        if let identifier = identifier as? String {
            if let brick = bricks[identifier], brickType = brick.type {
                brick.currentHits++
                if brick.currentHits >= brickType.hitsRequired {
                    
                    breakoutPhysics.removeBoundary(named: identifier)
                    self.bricks.removeValueForKey(identifier)
                    
                    // Required Tasks
                    // 2. When a brick is hit, some animation of the brick must occur. For example,
                    // the brick might flip over before fading out or it might flash another color
                    // before disappearing, etc. Show us that you know how to animate changes to a UIView.
                    
                    UIView.animateWithDuration(0.2,
                                               animations: {
                                                brick.alpha = 0
                        },
                                               completion: { didComplete in
                                                brick.alpha = brick.currentAlphaLevel
                                                UIView.animateWithDuration(0.2,
                                                    animations: {
                                                        brick.alpha = 0
                                                    },
                                                    completion: { didComplete in
                                                        brick.alpha = brick.currentAlphaLevel
                                                        UIView.animateWithDuration(0.8,
                                                            animations: {
                                                                brick.alpha = 0
                                                            },
                                                            completion: { didComplete in
                                                                brick.removeFromSuperview()
                                                            }
                                                        )
                                                    }
                                                )
                        }
                    )
                    
                    // drop power if its a special brick
                    if brickType != .Regular { dropSpecialBrickPowerAt(brick.center, brickType: brickType) }
                }
            }
        }
    }
    
    // MARK: - Special bricks
    
    // used to track special brick powers currently dropping, then the intersction of
    // paddle frame and the presentation layer frame of special  bricks powers currently
    // dropping is checked
    private var specialBrickPowersCurrentlyDropping = [BrickSpecialPower]()
    
    private func dropSpecialBrickPowerAt(dropPosition: CGPoint, brickType: BrickType) {
        let specialBrickPower = BrickSpecialPower(dropPosition: dropPosition, brickType: brickType)
        specialBrickPowersCurrentlyDropping.append(specialBrickPower)
        gameView.addSubview(specialBrickPower)
        
        UIView.animateWithDuration(10.0,
                                   animations: {
                                    specialBrickPower.center.y = self.gameView.frame.size.height
            },
                                   completion: { [unowned self, specialBrickPower] didComplete in
                                    specialBrickPower.removeFromSuperview()
                                    self.specialBrickPowersCurrentlyDropping.removeObject(specialBrickPower)
            }
        )
    }
    
    private func removeAllSpecialBrickPowersDropping() {
        for droppingPower in specialBrickPowersCurrentlyDropping {
            droppingPower.removeFromSuperview()
        }
        specialBrickPowersCurrentlyDropping = [BrickSpecialPower]()
    }
    
    // MARK: - Bricks
    
    // used to identify colliding bricks and remove them from superview
    private var bricks = [String:Brick]()
    
    
    private let brickHeight = 30
    private let bricksPerRow = 6
    private let topBrickDistanceFromTop = 100
    
    private func removeAllBricks() {
        for (identifier, brick) in bricks {
            breakoutPhysics.removeBoundary(named: identifier)
            brick.removeFromSuperview()
        }
        bricks = [String:Brick]()
    }
    
    // Hints
    // 12. Since the number of bricks is likely going to be configurable
    // (i.e. not fixed), you will almost certainly be creating and adding
    // the brick (and ball and paddle for that matter) UIViews in code rather
    // than through your storyboard (that’s one of the things this assignment
    // is intended to give you experience doing).
    
    private func createBricks() {
        guard bricks.isEmpty else { return }
        
        let brickRows = UserSettings.sharedInstance.numberOfTotalBricks / bricksPerRow
        
        var userEnabledSpecialBrickTypes = [Int]()
        if UserSettings.sharedInstance.specialBrickSmallerPaddleEnabled { userEnabledSpecialBrickTypes.append(BrickType.SmallerPaddle.rawValue) }
        if UserSettings.sharedInstance.specialBrickLargerPaddleEnabled { userEnabledSpecialBrickTypes.append(BrickType.LargerPaddle.rawValue) }
        if UserSettings.sharedInstance.specialBrickAddBallEnabled { userEnabledSpecialBrickTypes.append(BrickType.AddBall.rawValue) }
        if UserSettings.sharedInstance.specialBrickHardEnabled { userEnabledSpecialBrickTypes.append(BrickType.Hard.rawValue) }
        
        let maxSpecialBricks = UserSettings.sharedInstance.numberOfSpecialBricks
        var specialBricksMatrix = [(row: Int, col: Int)]()
        repeat {
            let randomRow = (brickRows).random()
            let randomCol = (bricksPerRow).random()
            let doesContainRandomPosition = specialBricksMatrix.contains({ (position: (row: Int, col: Int)) -> Bool in
                if position.row == randomRow && position.col == randomCol { return true } else { return false }
            })
            if doesContainRandomPosition == false {
                specialBricksMatrix.append((row: randomRow, col: randomCol))
            }
        } while specialBricksMatrix.count < maxSpecialBricks
        
        let brickWidth = gameView.bounds.size.width / CGFloat(bricksPerRow)
        
        for row in 0 ..< brickRows {
            for column in 0 ..< bricksPerRow {
                var frame = CGRect(origin: CGPointZero, size: CGSize(width: brickWidth, height: CGFloat(brickHeight)))
                frame.origin = CGPoint(x: column * Int(brickWidth), y: (row * brickHeight) + topBrickDistanceFromTop )
                
                let doesContainRandomPosition = specialBricksMatrix.contains({ (position: (row: Int, col: Int)) -> Bool in
                    if position.row == row && position.col == column { return true } else { return false }
                })
                
                var brick: Brick!
                if !userEnabledSpecialBrickTypes.isEmpty && doesContainRandomPosition == true {
                    let randomSpecialBrickTypeIndex = (userEnabledSpecialBrickTypes.count).random()
                    let randomSpecialBrickTypeRawValue = userEnabledSpecialBrickTypes[randomSpecialBrickTypeIndex]
                    if let brickType = BrickType(rawValue: randomSpecialBrickTypeRawValue) {
                        brick = Brick(frame: frame, type: brickType)
                    } else {
                        brick = Brick(frame: frame, type: .Regular)
                    }
                } else {
                    brick = Brick(frame: frame, type: .Regular)
                }
                
                gameView.addSubview(brick)
                
                // Hints
                // 4. It is highly recommended that you manage the collision behavior with
                // the bricks using boundaries in a UICollisionBehavior rather than having
                // those brick-drawing views actually participate in the collisions
                // themselves. You’ll have to keep the brick boundaries in sync with the
                // frames of the bricks, but the bricks don’t move once they are laid out
                // for a given bounds of your MVC’s View, so that should be very easy.
                // This is only a hint, not a required task.
                
                let brickPath = UIBezierPath(rect: brick.frame)
                let brickIdentifier = BoundaryNames.BrickBoundary + "\(row).\(column)"
                breakoutPhysics.addBoundary(brickPath, named: brickIdentifier)
                bricks[brickIdentifier] = brick
            }
        }
    }
    
    // MARK: - Paddle
    
    private var paddle: Paddle?
    
    private func createPaddle() {
        firstHitRequiredFromPaddle = true
        if paddle == nil {
            paddle = Paddle(referenceView: gameView)
            gameView.addSubview(paddle!)
            syncPaddleBoundary()
        }
    }
    
    private func removePaddle() {
        breakoutPhysics.removeBoundary(named: BoundaryNames.PaddleBoundary)
        paddle?.removeFromSuperview()
        paddle = nil
    }
    
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let velocity = gesture.velocityInView(gameView)
            if let paddle = paddle {
                paddle.move(velocity)
                
                // Hints
                // 23. Be careful not to move your paddle boundary right on
                // top of a bouncing ball or the ball might get trapped inside your paddle.
                var ballDidIntersect = false
                for ball in balls {
                    if CGRectIntersectsRect(paddle.frame, ball.frame) {
                        ballDidIntersect = true
                    }
                }
                if !ballDidIntersect {
                    syncPaddleBoundary()
                }
            }
            
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    
    // Hints
    // 6. The paddle, even though it moves in response to a pan gesture, probably also
    // wants to be a boundary (one that you are constantly removing and adding to the
    // UICollisionBehavior). Otherwise, when the ball hits the paddle, the paddle might
    // want to move in response and it should only move in response to the pan gesture.
    
    private func syncPaddleBoundary() {
        if let paddleView = paddle {
            // Why ovalInRect?
            // Specs, page 5: 26. You might want to make the bezier path boundary
            // for your paddle be an oval (even if the paddle itself still looks
            // like a rectangle). It makes the bouncing ball come off the paddle
            // more interestingly.
            
            var paddleBoundary: UIBezierPath!
            
            // When the game starts, we need the paddle boundary to be rectangular
            // otherwise the balls resting on the paddle will fall off the screen
            if firstHitRequiredFromPaddle {
                paddleBoundary = UIBezierPath(rect: paddleView.frame)
            } else {
                // Hints
                // 26. You might want to make the bezier path boundary for your paddle
                // be an oval (even if the paddle itself still looks like a rectangle).
                // It makes the bouncing ball come off the paddle more interestingly.
                
                paddleBoundary = UIBezierPath(ovalInRect: paddleView.frame)
            }
            breakoutPhysics.addBoundary(paddleBoundary, named: BoundaryNames.PaddleBoundary)
        }
    }
    
    // MARK: - Ball
    
    private let ballSize = CGSize(width: 20, height: 20)
    private var balls = [Ball]()
    private var firstHitRequiredFromPaddle = true
    
    // used to restore game when user taps the settings screen and comes back
    private var frozenBalls: [Ball]?
    
    private func restoreBalls() {
        if let frozenBalls = frozenBalls {
            balls = frozenBalls
            for ball in frozenBalls {
                breakoutPhysics.addBall(ball)
                breakoutPhysics.pushRestoredBall(ball)
            }
            self.frozenBalls = nil
        }
    }
    
    // Hints
    // 5. Pausing your game when you navigate away from it (to go to settings) is a bit of
    // a challenge (because you basically have to freeze the ball where it is, but when you
    // come back, you have to get the ball going with the same linear velocity it had).
    
    private func freezeBalls() {
        if !balls.isEmpty {
            frozenBalls = [Ball]()
            for ball in balls {
                ball.linearVelocity = breakoutPhysics.ballBehavior.linearVelocityForItem(ball)
                frozenBalls?.append(ball)
            }
        }
    }
    
    private func createBall() {
        if balls.count == 0 {
            let numberOfBouncingBalls = UserSettings.sharedInstance.numberOfBalls
            
            for i in 1...numberOfBouncingBalls {
                var frame = CGRect(origin: CGPointZero, size: ballSize)
                
                let widthOnPaddleForEachBall = (paddle?.bounds.size.width)! / CGFloat(numberOfBouncingBalls)
                let centerOfWidthOnPaddleForEachBall = widthOnPaddleForEachBall / 2
                
                frame.origin.x = (paddle?.frame.origin.x)!
                    + (widthOnPaddleForEachBall * CGFloat(i))
                    - centerOfWidthOnPaddleForEachBall
                    - (ballSize.width / 2)
                
                frame.origin.y = (paddle?.frame.origin.y)! - ballSize.height
                
                // Hints
                // 5. The bouncing ball, on the other hand, almost certainly does want to be
                // a UIView that is participating in the collisions (with the brick, paddle
                // and wall boundaries). That’s because the bouncing ball is moving all over
                // the place and you want the physics engine to be able to control its behavior.
                
                let ball = Ball(frame: frame)
                breakoutPhysics.addBall(ball)
                balls.append(ball)
            }
            
        } else {
            let lastBall = balls.last
            var frame = CGRect(origin: CGPointZero, size: ballSize)
            frame.origin.x = (lastBall?.frame.origin.x)!
            frame.origin.y = (lastBall?.frame.origin.y)!
            
            let ball = Ball(frame: frame)
            breakoutPhysics.addBall(ball)
            breakoutPhysics.pushBall(ball)
            balls.append(ball)
        }
    }
    
    private func removeBall(ball: Ball) {
        breakoutPhysics.removeBall(ball)
        balls.removeObject(ball)
    }
    
    private func removeAllBalls() {
        for ball in balls {
            removeBall(ball)
        }
    }
    
    // Required Tasks
    // 3. In addition to supporting a pan gesture to move the game’s paddle, you
    // must support a tap gesture which pushes the bouncing ball in a random
    // direction an appropriate (i.e. noticeable, but not game-destroying!) amount.
    
    @IBAction func pushBall(gesture: UITapGestureRecognizer) {
        if firstHitRequiredFromPaddle {
            for ball in balls {
                breakoutPhysics.pushBallFromPaddle(ball)
            }
            firstHitRequiredFromPaddle = false
            syncPaddleBoundary()
        } else {
            for ball in balls {
                breakoutPhysics.pushBall(ball)
            }
        }
    }
}

private extension Int {
    func random() -> Int {
        return Int(arc4random() % UInt32(self))
    }
}

private extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}

