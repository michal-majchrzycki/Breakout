import UIKit

class BreakoutViewController: UIViewController, BreakoutGameDelegate {
    
    @IBOutlet weak var breakoutGameView: UIView!

    
    lazy var breakoutGame: BrekoutPhysics = {
        let lazyBreakoutGame = BrekoutPhysics()
        lazyBreakoutGame.delegate = self
        return lazyBreakoutGame
    }()
    
    lazy var breakoutAnimator: UIDynamicAnimator = {
        let lazyBreakoutAnimator = UIDynamicAnimator(referenceView: self.breakoutGameView)
        return lazyBreakoutAnimator
    }()
    
    private var ballView: UIImageView? = nil
    
    private var paddleView: UIImageView? = nil
    
    private var brickViews: [[UIImageView]] = [[]]
    
    private struct Constants {
        struct Ball {
            static var Size: CGSize { return CGSize(width: AppDelegate.Settings.Ball.Size, height: AppDelegate.Settings.Ball.Size) }
            static var StartSpreadAngle: CGFloat { return AppDelegate.Settings.Ball.StartSpreadAngle }
            static let BackgroundColor = UIColor.clearColor()
            static let BorderWidth = CGFloat(0.0)
            static let BottomOffset = CGFloat(40.0)
        }
        struct Paddle {
            static let Size = CGSize(width: 100.0, height: 10.0)
            static let BottomOffset = CGFloat(15.0)
        }
        struct Brick {
            static var Rows: Int { return AppDelegate.Settings.Brick.Rows }
            static var Columns: Int { return AppDelegate.Settings.Brick.Columns }
            static let Gap = CGFloat(10.0)
            static let Height = CGFloat(30.0)
            static let TopOffset = CGFloat(100.0)
        }
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakoutAnimator.addBehavior(breakoutGame)
    }
    
    override func viewWillAppear(animated: Bool) {
        breakoutGame.resumeGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startGame()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        breakoutGame.pauseGame()
    }
    
    @IBAction func pushBall(tapGesture: UITapGestureRecognizer) {
        switch tapGesture.state {
        case .Ended:
            let angleBasePart = CGFloat(M_PI/2)
            let angleRandomSpread = CGFloat(Float(arc4random()) / Float(UINT32_MAX) - 0.5) * Constants.Ball.StartSpreadAngle
            let angle = angleBasePart + angleRandomSpread
            let magnitude = CGFloat(0.5)
            breakoutGame.pushView(ballView!, angle: angle, magnitude: magnitude)
        default:
            break
        }
    }
    
    @IBAction func pushPaddle(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .Began: fallthrough
        case .Changed: fallthrough
        case .Ended:
            let translation = panGesture.translationInView(breakoutGameView)
            breakoutGame.moveView(paddleView!, translation: translation)
            panGesture.setTranslation(CGPointZero, inView: breakoutGameView)
        default:
            break
        }
    }
    
    
    func startGame() {
        for view in breakoutGameView.subviews {
            breakoutGame.removeView(view, animated: false)
        }
        
        breakoutGameView.type = BreakoutViewType.Boundary
        breakoutGame.createBoundary(breakoutGameView)
        breakoutGameView.backgroundColor = UIColor(patternImage: UIImage(named: "cavepaintings.jpg")!)
        
        let ballViewOrigin = CGPoint(x: breakoutGameView.bounds.midX - Constants.Ball.Size.width / 2,
                                     y: breakoutGameView.bounds.maxY - Constants.Ball.BottomOffset - Constants.Ball.Size.height / 2)
        ballView = UIImageView(frame: CGRect(origin: ballViewOrigin, size: Constants.Ball.Size))
        ballView!.layer.backgroundColor = Constants.Ball.BackgroundColor.CGColor
        ballView!.image = UIImage(named: "stone")
        ballView!.layer.borderWidth = Constants.Ball.BorderWidth
        ballView!.layer.cornerRadius = Constants.Ball.Size.height / 2.0
        ballView!.type = BreakoutViewType.Ball
        breakoutGame.addView(ballView!)
        
        let paddleViewOrigin = CGPoint(x: breakoutGameView.bounds.midX - Constants.Paddle.Size.width / 2,
                                       y: breakoutGameView.bounds.maxY - Constants.Paddle.BottomOffset)
        paddleView = UIImageView(frame: CGRect(origin: paddleViewOrigin, size: Constants.Paddle.Size))
        paddleView!.layer.cornerRadius = Constants.Paddle.Size.height / 2
        paddleView!.image = UIImage(named: "paddle")
        paddleView!.type = BreakoutViewType.Paddle
        breakoutGame.addView(paddleView!)
        
        let brickViewSize = CGSize(width: (breakoutGameView.bounds.width - Constants.Brick.Gap * CGFloat(Constants.Brick.Columns + 1))
            / CGFloat(Constants.Brick.Columns),
                                   height: Constants.Brick.Height)
        brickViews.reserveCapacity(Constants.Brick.Rows)
        for row in 0 ..< Constants.Brick.Rows {
            var bricksColumn: [UIImageView] = []
            bricksColumn.reserveCapacity(Constants.Brick.Columns)
            for column in 0 ..< Constants.Brick.Columns {
                let brickViewOrigin = CGPoint(x: Constants.Brick.Gap + (brickViewSize.width + Constants.Brick.Gap) * CGFloat(column),
                                              y:  Constants.Brick.TopOffset + (brickViewSize.height + Constants.Brick.Gap) * CGFloat(row))
                let brickView = UIImageView(frame: CGRect(origin: brickViewOrigin, size: brickViewSize))
                brickView.layer.cornerRadius = Constants.Brick.Height / 4.0
                brickView.image = UIImage(named: "rock-brick")
                brickView.type = BreakoutViewType.Brick
                bricksColumn.insert(brickView, atIndex: column)
                breakoutGame.addView(brickView)
            }
            brickViews.insert(bricksColumn, atIndex: row)
        }
    }
    
    func winGame() {
        let alert = UIAlertController(title: "YOU HAVE WIN", message: "You can restart game", preferredStyle: UIAlertControllerStyle.Alert)
        let newGameAction = UIAlertAction(title: "Reset Game", style: UIAlertActionStyle.Cancel) {
            (action: UIAlertAction!) -> Void in
            self.startGame()
        }
        alert.addAction(newGameAction)
        breakoutGame.pauseGame()
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func endGame() {
        let alert = UIAlertController(title: "GAME IS OVER", message: "You can play or reset game", preferredStyle: UIAlertControllerStyle.Alert)
        let newGameAction = UIAlertAction(title: "Reset Game", style: UIAlertActionStyle.Cancel) {
            (action: UIAlertAction!) -> Void in
            self.startGame()
        }
        alert.addAction(newGameAction)
        if AppDelegate.Settings.Game.ContinueAfterGameOver == true {
            let continueAction = UIAlertAction(title: "Play", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                self.breakoutGame.resumeGame()
            }
            alert.addAction(continueAction)
        }
        breakoutGame.pauseGame()
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

