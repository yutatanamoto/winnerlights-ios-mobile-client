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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Avairable Exercises"
        self.view.addSubview(exerciseCollectionView)
        setupConstraint()
    }
    
    func setupConstraint() {
        exerciseCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        exerciseCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        exerciseCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        exerciseCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension AvairableExercisesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ExerciseCollectionViewCell
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
