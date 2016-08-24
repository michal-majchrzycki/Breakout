import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet var movePaddle: UIPanGestureRecognizer!
    
    private lazy var animator: UIDynamicAnimator = {
        
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        
        #if DEBUG
            lazilyCreatedDynamicAnimator.debugEnabled = true
        #endif
        
        return lazilyCreatedDynamicAnimator
        
    }()
    
    struct BoundaryNames {
        static let gameViewLeftBoundary = "Game View Left Boundary"
        static let gameViewTopBoundary = "Game View Top Boundary"
        static let gameViewRightBoundary = "Game View Right Boundary"
        static let paddleBoundary = "Paddle Boundary"
        static let brickBoundary = "Brick Boundary"
    }
    
    private let brekoutPhysics = BrekoutPhysics()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameOverLabel.hidden = true
        self.startGameButton.hidden = false
        
        animator.addBehavior(brekoutPhysics)
        brekoutPhysics.colidePhysics.collisionDelegate = self
        brekoutPhysics.colidePhysics.action = { [unowned self] in
            if self.gameView.hidden == true {
                
                for ball in self.balls {
                    if !CGRectIntersectsRect(ball.frame, self.gameView.frame) { self.removeBall(ball) }
                }
                
                if self.balls.count == 0 && self.frozenBall == nil {
                    print("Game Over!")
                }
                
                if self.balls.count > 0 && self.bricks.count == 0 {
                    self.removeAllBalls()
                    print("Win!!")
                }
            }
        }

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "settingsDidUpdate",
                                                         name: "BreakoutViewControllerUpdateSettings",
                                                         object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if frozenBall != nil {
            gameView.hidden = true
            restoreBalls()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if !balls.isEmpty {
            freezeBall()
            removeAllBalls()
        }
    }
    

    
    @IBAction func LetsStartGame(sender: UIButton) {
        startGameButton.hidden = true
        showBricks()
        gameView.userInteractionEnabled = true
        movePaddle.enabled = true
        createPaddle()
        addGameViewBoundary()
        createBall()
    }
    
    private func gameOver() {
        gameView.userInteractionEnabled = false
        movePaddle.enabled = false
        
        gameView.hidden = false
        
        removePaddle()
        removeAllBricks()
    }
    
    // Mark: Ball
    
    private let ballSize = CGSize(width: 30, height: 30)
    private var balls = [Ball]()
    private var firstHitRequiredFromPaddle = true
    
    private var frozenBall: [Ball]?
    
    private func restoreBalls() {
        if let frozenBall = frozenBall {
            balls = frozenBall
            for ball in frozenBall {
                brekoutPhysics.addBall(ball)
                brekoutPhysics.pushRestoredBall(ball)
            }
            self.frozenBall = nil
        }
    }
    
    private func freezeBall() {
        if !balls.isEmpty {
            frozenBall = [Ball]()
            for ball in balls {
                ball.linearVelocity = brekoutPhysics.ballPhysics.linearVelocityForItem(ball)
                frozenBall?.append(ball)
            }
        }
    }
    
    private func createBall() {
        if balls.count == 0 {
            let bouncingBall = 1
            
            for i in 1...bouncingBall {
                var frame = CGRect(origin: CGPointZero, size: ballSize)
                
                let widthOnPaddleForEachBall = (paddle?.bounds.size.width)! / CGFloat(bouncingBall)
                let centerOfWidthOnPaddleForEachBall = widthOnPaddleForEachBall / 2
                
                frame.origin.x = (paddle?.frame.origin.x)!
                    + (widthOnPaddleForEachBall * CGFloat(i))
                    - centerOfWidthOnPaddleForEachBall
                    - (ballSize.width / 2)
                
                frame.origin.y = (paddle?.frame.origin.y)! - ballSize.height
                
                let ball = Ball(frame: frame)
                brekoutPhysics.addBall(ball)
                balls.append(ball)
            }
            
        } else {
            let lastBall = balls.last
            var frame = CGRect(origin: CGPointZero, size: ballSize)
            frame.origin.x = (lastBall?.frame.origin.x)!
            frame.origin.y = (lastBall?.frame.origin.y)!
            
            let ball = Ball(frame: frame)
            brekoutPhysics.addBall(ball)
            brekoutPhysics.ballPhysics(ball)
            balls.append(ball)
        }
    }
    
    private func removeBall(ball: Ball) {
        brekoutPhysics.removeBall(ball)
    }
    
    private func removeAllBalls() {
        for ball in balls {
            removeBall(ball)
        }
    }
    
    // Mark: Paddle
    
    private var paddle: Paddle?
    
    private func createPaddle() {
        firstHitRequiredFromPaddle = true
        if paddle == nil {
            paddle = Paddle(referenceView: gameView)
            gameView.addSubview(paddle!)
            syncPaddleBounds()
        }
    }
    
    private func removePaddle() {
        brekoutPhysics.removeBounds(named: BoundaryNames.paddleBoundary)
        paddle?.removeFromSuperview()
        paddle = nil
    }
    
    @IBAction func movePaddleOn(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let velocity = gesture.velocityInView(gameView)
            if let paddle = paddle {
                paddle.moveStuff(velocity)
                
                var ballDidIntersect = false
                for ball in balls {
                    if CGRectIntersectsRect(paddle.frame, ball.frame) {
                        ballDidIntersect = true
                    }
                }
                if !ballDidIntersect {
                    syncPaddleBounds()
                }
            }
            
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    private func syncPaddleBounds() {
        if let paddleView = paddle {
                     var paddleBoundary: UIBezierPath!
            
            if firstHitRequiredFromPaddle {
                paddleBoundary = UIBezierPath(rect: paddleView.frame)
            } else {
                // Hints
    
                
                paddleBoundary = UIBezierPath(ovalInRect: paddleView.frame)
            }
            brekoutPhysics.addBounds(paddleBoundary, named: BoundaryNames.paddleBoundary)
        }
    }
    
    private func gameViewBounds() {
        
        let gameViewLeftBounds = UIBezierPath()
        let gameViewTopBounds = UIBezierPath()
        let gameViewRightBounds = UIBezierPath()
        
        gameViewLeftBounds.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.size.height))
        gameViewLeftBounds.addLineToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        gameViewTopBounds.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        gameViewTopBounds.addLineToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.origin.y))
        gameViewRightBounds.moveToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.origin.y))
        gameViewRightBounds.addLineToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.size.height))
        
        brekoutPhysics.addBounds(gameViewLeftBounds, named: BoundaryNames.gameViewLeftBoundary)
        brekoutPhysics.addBounds(gameViewTopBounds, named: BoundaryNames.gameViewTopBoundary)
        brekoutPhysics.addBounds(gameViewRightBounds, named: BoundaryNames.gameViewRightBoundary)
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
        if let identifier = identifier as? String {
            if let brick = bricks[identifier], brickType = brick.type {
                brick.currentHits += 1
                if brick.currentHits >= brickType.hitsRequired {
                    
                    brekoutPhysics.removeBounds(named: identifier)
                    self.bricks.removeValueForKey(identifier)
                    
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
                }
            }
        }
    }
    
    
    
    // Mark: Brick
    
    private var bricks = [String:Brick]()
    private let brickHeight = 40
    private let bricksPerRow = 6
    private let topBrickDistanceFromTop = 40
    
    private func removeAllBricks() {
        for (identifier, brick) in bricks {
            brekoutPhysics.removeBounds(named: identifier)
            brick.removeFromSuperview()
        }
        bricks = [String:Brick]()
    }
    
    private func showBricks() {
        guard bricks.isEmpty else { return }
        let brickWidth = gameView.bounds.size.width / CGFloat(bricksPerRow)
        let brickRows = 6 / bricksPerRow
        var specialBricksMatrix = [(row: Int, col: Int)]()
        
        
        for row in 0 ..< brickRows {
            for column in 0 ..< bricksPerRow {
                var frame = CGRect(origin: CGPointZero, size: CGSize(width: brickWidth, height: CGFloat(brickHeight)))
                frame.origin = CGPoint(x: column * Int(brickWidth), y: (row * brickHeight) + topBrickDistanceFromTop )
                
                let doesContainRandomPosition = specialBricksMatrix.contains({ (position: (row: Int, col: Int)) -> Bool in
                    if position.row == row && position.col == column { return true } else { return false }
                })
                
                var brick: Brick!
                if doesContainRandomPosition == true {
                    let randomSpecialBrickTypeIndex = random()
                    if let brickType = BrickType(rawValue: randomSpecialBrickTypeIndex) {
                        brick = Brick(frame: frame, type: brickType)
                    } else {
                        brick = Brick(frame: frame, type: .Regular)
                    }
                } else {
                    brick = Brick(frame: frame, type: .Regular)
                }
                
                gameView.addSubview(brick)
                
                let brickPath = UIBezierPath(rect: brick.frame)
                let brickIdentifier = BoundaryNames.brickBoundary + "\(row).\(column)"
                brekoutPhysics.addBounds(brickPath, named: brickIdentifier)
                bricks[brickIdentifier] = brick
            }
        }
    }
    
    
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
    }
    
    
}

