//
//  AvairableExercisesViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by human on 2020/09/23.
//

import UIKit

class AvairableExercisesViewController: UIViewController {
    let numberOfColumns: CGFloat = 2
    let marginWidth: CGFloat = 20
    let cornerRadius: CGFloat = 20
    let shadowOpacity: Float = 0.2
    let shadowOffset: CGSize = CGSize(width: 4, height: 4)
    let topMarginWidth: CGFloat = 10
    let bottomMarginWidth: CGFloat = 10
    let buttonHeight: CGFloat = 60
    var backButtonTappedAt: Float = 0
    var exercises: [Exercise] = [
            Exercise(
            title: "Counter attack",
            description: "There are four goals on the pitch. The game direction changes in the modified amount of time. So two goals are enlightened in the same color.The teams stay the same.",
            phases: [
                Phase(
                    duration: 5,
                    goals: [
                        Goal(position: .upperLeft, color: .pink),
                        Goal(position: .lowerLeft, color: .pink),
                        Goal(position: .upperRight, color: .blue),
                        Goal(position: .lowerRight, color: .blue),
                    ]
                ),
                Phase(
                    duration: 5,
                    goals: [
                        Goal(position: .upperLeft, color: .blue),
                        Goal(position: .lowerLeft, color: .blue),
                        Goal(position: .upperRight, color: .pink),
                        Goal(position: .lowerRight, color: .pink),
                    ]
                ),
                Phase(
                    duration: 5,
                    goals: [
                        Goal(position: .upperLeft, color: .pink),
                        Goal(position: .lowerLeft, color: .pink),
                        Goal(position: .upperRight, color: .blue),
                        Goal(position: .lowerRight, color: .blue),
                    ]
                ),
                Phase(
                    duration: 5,
                    goals: [
                        Goal(position: .upperLeft, color: .blue),
                        Goal(position: .lowerLeft, color: .blue),
                        Goal(position: .upperRight, color: .pink),
                        Goal(position: .lowerRight, color: .pink),
                    ]
                )
            ]
        ),
        Exercise(
        title: "Diagonal",
        description: "There are four goals on the pitch. Respectively two goals are enlightened in the same color. These goals diagonally have the same color, so the attacking/ defending change has to be organised diagonally. The teams stay the same.",
        phases: [
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .blue),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .pink),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .blue),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .pink),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .blue),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .pink),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .blue),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .pink),
                ]
            )
          ]
        ),
        Exercise(
        title: "Powerplay",
        description: "All goals are alternately lighting in the same color. By that, one team has to defend all or attach all goals. The other team has to do the opposite.The teams stay the same.",
        phases: [
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .blue),
                    Goal(position: .lowerLeft, color: .blue),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .pink),
                    Goal(position: .lowerRight, color: .pink),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .blue),
                    Goal(position: .lowerLeft, color: .blue),
                    Goal(position: .upperRight, color: .blue),
                    Goal(position: .lowerRight, color: .blue),
                ]
            ),
            Phase(
                duration: 5,
                goals: [
                    Goal(position: .upperLeft, color: .pink),
                    Goal(position: .lowerLeft, color: .pink),
                    Goal(position: .upperRight, color: .pink),
                    Goal(position: .lowerRight, color: .pink),
                ]
            )
        ]
      )
    ]
    
    // Initialization closures
    fileprivate lazy var exerciseCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ExerciseCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRadius
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = shadowOffset
        button.setTitle("+ Create New Exercise", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
//        button.addTarget(self, action: #selector(someFunc), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Available Exercises"
        self.view.addSubview(exerciseCollectionView)
        //self.view.addSubview(addButton)
        setupConstraint()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        setupConstraint()
    }
    
    func setupConstraint() {
        let guide = view.safeAreaLayoutGuide
        exerciseCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        exerciseCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        exerciseCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        exerciseCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        addButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20).isActive = true
//        addButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
//        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        addButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
}

extension AvairableExercisesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ExerciseCollectionViewCell
//        cell.exercise = exercises[indexPath.row]
        let cellExercise = exercises[indexPath.row]
        cell.exerciseChange(exercise: cellExercise)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-marginWidth)/numberOfColumns
        let height = (collectionView.frame.width-marginWidth)/numberOfColumns
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let vc = ExerciseDetailViewController()
        vc.exercise = exercises[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
