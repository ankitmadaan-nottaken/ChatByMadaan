//
//  WelcomeViewController.swift
//  ChatByMadaan
//
//  Created by Ankit Madan on 6/17/25.
//

import Foundation
import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

    private let appImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "message.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ChatByMadaan"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "Conversations that matter."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        [appImageView, titleLabel, taglineLabel, loginButton, registerButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            appImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            appImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appImageView.widthAnchor.constraint(equalToConstant: 100),
            appImageView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: appImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            loginButton.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 40),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            registerButton.leadingAnchor.constraint(equalTo: loginButton.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor),
            registerButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor)
        ])
    }

    @objc private func didTapLogin() {
        navigationController?.pushViewController(LoginViewController(), animated: true)
    }

    @objc private func didTapRegister() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
               // User is already logged in
               print("🔐 User remembered. Redirecting to Chat...")
               navigationController?.setViewControllers([ChatViewController()], animated: false)
           }

        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut],
                       animations: {
            self.appImageView.alpha = 1
            self.appImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })

        UIView.animate(withDuration: 0.4,
                       delay: 0.3,
                       options: [.curveEaseOut],
                       animations: {
            self.titleLabel.alpha = 1
            self.taglineLabel.alpha = 1
            self.titleLabel.transform = .identity
            self.taglineLabel.transform = .identity
        })

        UIView.animate(withDuration: 0.4,
                       delay: 0.6,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
            self.loginButton.alpha = 1
            self.registerButton.alpha = 1
            self.loginButton.transform = .identity
            self.registerButton.transform = .identity
        })
    }

}

