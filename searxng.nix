{
  config,
  pkgs,
  ...
}: {
  # System-level SOPS secrets configuration for SearXNG
  sops = {
    defaultSopsFile = ./secrets/keys.yml;
    age.keyFile = "/home/devtrung/.config/sops/age/keys.txt";

    secrets.searxng_secret_key = {
      owner = "searx";
    };
    secrets.brave_api_key = {
      owner = "searx";
    };

    templates."searxng.env" = {
      content = ''
        SEARX_SECRET_KEY="${config.sops.placeholder.searxng_secret_key}"
        BRAVE_API_KEY="${config.sops.placeholder.brave_api_key}"
      '';
      owner = "searx";
      restartUnits = [ "searx-init.service" "searx.service" ];
    };
  };

  # SearXNG meta search engine
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    environmentFile = config.sops.templates."searxng.env".path;

    settings = {
      server = {
        port = 8888;
        bind_address = "127.0.0.1";
        secret_key = "$SEARX_SECRET_KEY";
      };

      search = {
        safe_search = 0;
        autocomplete = "duckduckgo";
        formats = [
          "html"
          "json"
        ];
      };

      ui = {
        default_theme = "simple";
        theme_args.simple_style = "dark";
      };

      engines = [
        # Brave Search API (Requires API Key from https://brave.com/search/api/)
        {
          name = "braveapi";
          engine = "braveapi";
          shortcut = "brav";
          api_key = "$BRAVE_API_KEY";
          disabled = false;
          inactive = false;
        }

        # Major Web Search Engines
        {
          name = "google";
          engine = "google";
          disabled = false;
        }
        {
          name = "bing";
          engine = "bing";
          disabled = false;
        }
        {
          name = "duckduckgo";
          engine = "duckduckgo";
          disabled = false;
        }
        {
          name = "brave";
          engine = "brave";
          disabled = false;
        }

        # Knowledge, Science & Tech
        {
          name = "arxiv";
          engine = "arxiv";
          shortcut = "arx";
          disabled = false;
        }
        {
          name = "wikipedia";
          engine = "wikipedia";
          disabled = false;
        }
        {
          name = "wikidata";
          engine = "wikidata";
          disabled = false;
        }
        {
          name = "github";
          engine = "github";
          disabled = false;
        }
        {
          name = "stackoverflow";
          engine = "stackoverflow";
          disabled = false;
        }
        {
          name = "nixos wiki";
          engine = "nixos wiki";
          disabled = false;
        }
        {
          name = "arch linux wiki";
          engine = "arch linux wiki";
          disabled = false;
        }

        # Image Search Engines
        {
          name = "bing images";
          disabled = false;
        }
        {
          name = "brave.images";
          disabled = false;
        }
        {
          name = "duckduckgo images";
          disabled = false;
        }
        {
          name = "google cse images";
          disabled = false;
        }
        {
          name = "google images";
          disabled = true;
        }
        {
          name = "openverse";
          disabled = false;
        }
        {
          name = "flickr";
          disabled = false;
        }
      ];
    };
  };
}
