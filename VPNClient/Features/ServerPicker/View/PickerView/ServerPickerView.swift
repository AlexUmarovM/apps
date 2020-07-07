//
//  ServerPickerView.swift
//  VPNClient
//
//  Created by Igor Kasyanenko on 10.05.2020.
//  Copyright © 2020 VPNUK. All rights reserved.
//

import UIKit

typealias Action = () -> ()

class ServerPickerView: UIView {
    
    var viewTappedAction: Action?
    
    var state: State = .notPicked {
        didSet {
            update(with: state)
        }
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(recognizer)
        setupSubviews()
        setupConstraints()
        
        state = .notPicked
    }
    
    private func update(with state: State) {
        removeSubviews()
        switch state {
        case .picked(let server, let isConnected):
            let view = ServerPickerPickedView()
            view.update(withServerEntity: server, isConnected: isConnected)
            addSubview(view)
            view.makeEdgesEqualToSuperview()
        case .notPicked:
            let view = ServerPickerNotPickedView()
            addSubview(view)
            view.makeEdgesEqualToSuperview()
        }
    }
    
    private func setupSubviews() {
        backgroundColor = .white
        
        makeDefaultShadowAndCorners()
    }
    
    private func setupConstraints() {
        snp.makeConstraints { (make) in
            make.height.equalTo(105).priority(.medium)
            make.width.equalTo(280)
        }
    }
    
    @objc private func viewTapped() {
        viewTappedAction?()
    }
}

extension ServerPickerView {
    enum State {
        case picked(server: ServerEntity, isConnected: Bool)
        case notPicked
    }
}
