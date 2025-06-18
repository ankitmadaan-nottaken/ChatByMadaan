//
//  ChatTableViewCell.swift
//  ChatByMadaan
//
//  Created by Ankit Madan on 6/11/25.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    let bubbleBackground = UIView()
    let messageLabel = UILabel()

    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    let senderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .darkGray
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 10)
        label.textColor = .gray
        label.textAlignment = .right
        label.backgroundColor = .yellow.withAlphaComponent(0.3)

        return label
    }()

    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var senderLeadingConstraint: NSLayoutConstraint!
    var senderTrailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        statusLabel.numberOfLines = 1

        bubbleBackground.layer.cornerRadius = 16
        bubbleBackground.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        senderLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        senderLabel.isHidden = false

        // Add subviews
        bubbleBackground.addSubview(messageLabel)
        bubbleBackground.addSubview(timestampLabel)
        bubbleBackground.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleBackground)
        contentView.addSubview(senderLabel)
        
        NSLayoutConstraint.activate([
            // Sender label (above the bubble)
            senderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),

            // Bubble top below sender label
            bubbleBackground.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 2),
            bubbleBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleBackground.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            // Message label (top inside bubble)
            messageLabel.topAnchor.constraint(equalTo: bubbleBackground.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackground.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackground.trailingAnchor, constant: -12),

            // Timestamp label (below message)
            timestampLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            timestampLabel.leadingAnchor.constraint(equalTo: bubbleBackground.leadingAnchor, constant: 12),
            timestampLabel.trailingAnchor.constraint(equalTo: bubbleBackground.trailingAnchor, constant: -12),

            // Status label (below timestamp)
            statusLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 2),
            statusLabel.leadingAnchor.constraint(equalTo: bubbleBackground.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: bubbleBackground.trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(equalTo: bubbleBackground.bottomAnchor, constant: -8)
        ])


        // Alignment constraints (not activated yet)
        leadingConstraint = bubbleBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        senderLeadingConstraint = senderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        senderTrailingConstraint = senderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    }

    func configure(with message: Message, isCurrentUser: Bool, showSender: Bool) {
        messageLabel.text = message.text
        bubbleBackground.backgroundColor = isCurrentUser ? .systemBlue : .lightGray
        messageLabel.textColor = isCurrentUser ? .white : .black

        statusLabel.textAlignment = .right
        statusLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
        statusLabel.setContentCompressionResistancePriority(.required, for: .vertical)


        NSLayoutConstraint.deactivate([leadingConstraint, trailingConstraint, senderLeadingConstraint, senderTrailingConstraint])
        print("📎 Status: \(statusLabel.text ?? "nil") (Hidden: \(statusLabel.isHidden))")

        if isCurrentUser {
            trailingConstraint.isActive = true
            senderTrailingConstraint.isActive = true
            senderLabel.textAlignment = .right
            senderLabel.text = "You"
            senderLabel.textColor = .systemBlue
            statusLabel.text = message.status.rawValue.capitalized
            statusLabel.textColor = .white
            statusLabel.isHidden = false
        } else {
            leadingConstraint.isActive = true
            senderLeadingConstraint.isActive = true
            senderLabel.textAlignment = .left
            senderLabel.text = message.senderID
            senderLabel.textColor = .darkGray
            statusLabel.text = ""
            statusLabel.isHidden = true
        }


        senderLabel.isHidden = !showSender

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timestampLabel.text = formatter.string(from: message.timestamp)

        // Debug output
        print("📐 bubble frame: \(bubbleBackground.frame)")
        print("📐 senderLabel frame: \(senderLabel.frame)")
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        NSLayoutConstraint.deactivate([leadingConstraint, trailingConstraint, senderLeadingConstraint, senderTrailingConstraint])
        senderLabel.isHidden = false
    }



}
