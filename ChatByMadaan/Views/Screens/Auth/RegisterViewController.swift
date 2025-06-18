//
//  RegisterViewController.swift
//  ChatByMadaan
//
//  Created by Ankit Madan on 6/17/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    private let viewModel = RegisterViewModel()

    // MARK: - UI Components

    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        field.borderStyle = .roundedRect
        return field
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.borderStyle = .roundedRect
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        return field
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let stackView = UIStackView()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .systemBackground

        setupViews()
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupViews() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        [nameField, emailField, passwordField, registerButton].forEach { stackView.addArrangedSubview($0) }

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Actions

    @objc private func didTapRegister() {
            guard let name = nameField.text, !name.isEmpty,
                  let email = emailField.text, !email.isEmpty,
                  let password = passwordField.text, !password.isEmpty else {
                showAlert(title: "Missing Info", message: "Please fill in all fields.")
                return
            }

            viewModel.register(name: name, email: email, password: password) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.navigateToContacts()
                    case .failure(let error):
                        self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                    }
                }
            }
        }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func navigateToContacts() {
        let contactsVC = ContactsViewController()
        let nav = UINavigationController(rootViewController: contactsVC)

        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
        }

    }
}
