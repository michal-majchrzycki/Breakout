import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var gameView: UIView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startGameButton.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func LetsStartGame(sender: UIButton) {
        startGameButton.hidden = true
        showBricks()
    }
    
    // Mark: Paddle
    
    private var paddle: Paddle?
    
    private func createPaddle() {
        if paddle == nil {
            paddle = Paddle(referenceView: gameView)
            gameView.addSubview(paddle!)
        }
    }
    
    private func removePaddle() {
        paddle?.removeFromSuperview()
        paddle = nil
    }

    // Mark: Brick
    
    private var bricks = [String:Brick]()
    private let brickHeight = 30
    private let bricksPerRow = 6
    private let topBrickDistanceFromTop = 100
    
    private func removeAllBricks() {
        for (identifier, brick) in bricks {
            brick.removeFromSuperview()
        }
        bricks = [String:Brick]()
    }

    private func showBricks() {
        guard bricks.isEmpty else { return }
        let brickWidth = gameView.bounds.size.width / CGFloat(bricksPerRow)
        
        for row in 0 ..< bricksPerRow {
            for column in 0 ..< bricksPerRow {
                var frame = CGRect(origin: CGPointZero, size: CGSize(width: brickWidth, height: CGFloat(brickHeight)))
                frame.origin = CGPoint(x: column * Int(brickWidth), y: (row * brickHeight) + topBrickDistanceFromTop )
                
                var brick: Brick!

                gameView.addSubview(brick)
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

