# frozen_string_literal: true

# README screenshots. Run by the "Screenshots" workflow, which commits the PNGs
# to docs/screenshots/. Skipped in regular CI.
RSpec.describe "Screenshots" do
  fab!(:author) { Fabricate(:user, username: "satoshi") }
  fab!(:docs) { Fabricate(:category, name: "Docs") }
  fab!(:guides) { Fabricate(:category, name: "Guides") }
  fab!(:wiki) { Fabricate(:tag, name: "wiki") }

  before do
    skip "set SCREENSHOTS=1 to take screenshots" unless ENV["SCREENSHOTS"]

    SiteSetting.tagging_enabled = true
    SystemThemesManager.sync_theme!("horizon")
    horizon = Theme.horizon_theme
    horizon.update!(enabled: true, user_selectable: true)
    SiteSetting.default_theme_id = horizon.id

    component = upload_theme_component(parent_theme_id: horizon.id)
    component.update_setting(:tag_name, "wiki")
    component.update_setting(:target_category, docs.id.to_s)
    component.save!

    Fabricate(:topic_with_op, title: "Getting started with the docs", category: docs, user: author)
    Fabricate(:topic_with_op, title: "How we write our guides", category: docs, user: author)

    ["Setting up a wallet from scratch", "Backing up your seed phrase"].each do |title|
      Fabricate(:topic_with_op, title: title, category: guides, user: author, tags: [wiki])
    end
  end

  def save(name)
    path = Rails.root.join("tmp/capybara/screenshots/#{name}.png")
    FileUtils.mkdir_p(path.dirname)
    page.driver.with_playwright_page { |pw| pw.screenshot(path: path.to_s) }
  end

  it "shows merged topics on desktop" do
    resize_window(width: 1280, height: 900) do
      visit "/c/#{docs.slug}/#{docs.id}"
      expect(page).to have_css(".topic-list-item.doc-categories-tags-topic", count: 2)
      save("doc-tags-desktop")
    end
  end

  it "shows merged topics on mobile" do
    resize_window(width: 390, height: 844) do
      visit "/c/#{docs.slug}/#{docs.id}"
      expect(page).to have_css(".topic-list-item.doc-categories-tags-topic", count: 2)
      save("doc-tags-mobile")
    end
  end
end
