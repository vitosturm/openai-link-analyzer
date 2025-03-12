import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";
import { Promise } from "rsvp";

acceptance("OpenAI Link Analyzer - User Interface", function (needs) {
  needs.user();
  needs.settings({
    openai_link_analyzer_enabled: true,
  });

  test("Plugin UI is visible for logged in users", async function (assert) {
    await visit("/u/eviltrout/openai-link-analyzer");

    assert.ok(
      exists(".openai-link-analyzer-container"),
      "Plugin container is visible"
    );
    assert.ok(
      exists(".analyzer-form"),
      "Analyzer form is displayed"
    );
    assert.ok(
      exists(".analyzer-url-input"),
      "URL input field is available"
    );
    assert.ok(
      exists(".category-chooser"),
      "Category selection dropdown is available"
    );
    assert.ok(
      exists(".analyze-button"),
      "Analyze button is available"
    );
  });
});

acceptance("OpenAI Link Analyzer - Admin Panel", function (needs) {
  needs.user({ admin: true });
  needs.settings({
    openai_link_analyzer_enabled: true,
  });

  test("Admin panel is accessible for admins", async function (assert) {
    await visit("/admin/plugins/openai-link-analyzer");

    assert.ok(
      exists(".openai-link-analyzer-admin"),
      "Admin panel is visible"
    );
    assert.ok(
      exists(".admin-controls"),
      "Admin controls are displayed"
    );
    assert.ok(
      exists(".test-api-button"), 
      "Test API button is available"
    );
    assert.ok(
      exists(".stats-cards") || exists(".no-stats-message"),
      "Statistics section is available"
    );
  });
});

acceptance("OpenAI Link Analyzer", function (needs) {
  needs.user();
  needs.settings({
    openai_link_analyzer_enabled: true,
    openai_api_key: "test-api-key",
  });
  needs.pretender((server, helper) => {
    server.get("/openai-link-analyzer/categories", () => {
      return helper.response({
        categories: [
          { id: 1, name: "Test Category" },
          { id: 2, name: "Another Category" },
        ],
      });
    });
  });

  test("User page - Plugin UI is visible for logged in user", async function (assert) {
    await visit("/u/eviltrout/openai-link-analyzer");
    
    assert.ok(exists(".openai-link-analyzer"), "Plugin container is visible");
    assert.ok(exists(".analyzer-form"), "Analyzer form is present");
    assert.ok(exists("#url-input"), "URL input field is present");
    assert.ok(exists("button.btn-primary"), "Analyze button is present");
  });
});

acceptance("OpenAI Link Analyzer - Admin", function (needs) {
  needs.user({ admin: true });
  needs.settings({
    openai_link_analyzer_enabled: true,
    openai_api_key: "test-api-key",
  });
  needs.pretender((server, helper) => {
    server.get("/openai-link-analyzer/statistics", () => {
      return helper.response({
        success: true,
        stats: {
          total_analyzed: 5,
          success_rate: 80,
          last_analyzed: new Date().toISOString(),
          popular_categories: [
            { id: 1, name: "Test Category", count: 3 },
            { id: 2, name: "Another Category", count: 2 },
          ],
        },
      });
    });
  });

  test("Admin panel is accessible for admins", async function (assert) {
    await visit("/admin/plugins/openai-link-analyzer");
    
    assert.ok(exists(".openai-link-analyzer-admin"), "Admin panel is visible");
    assert.ok(exists(".stats-cards"), "Statistics cards are present");
    assert.ok(exists(".stat-card"), "At least one stat card is present");
  });
}); 