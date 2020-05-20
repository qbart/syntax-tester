import React, { useState, useCallback } from "react";
import store from "store";

import { rootDomainUrl } from "@utils/url";

import { Container, Items, Item, Link } from "./style";

const STORE_KEY = "accepts-cookies";

const object = {
  bool: true,
  number: 23,
  float: 43.44,
  string: "hello",
  other: null,
  empty: undefined,
  arr: [1, 2, "hello"]
};

class Cookie extends React.Component {
  constructor(props) {
    super(props);
  }

  handleOnClick = () => {
    setTimeout(() => console.log("hello"), 1000);
  };

  render() {
    return (
      <div>
        <span>Cookie Banner!</span>
      </div>
    );
  }
}

const CookieBanner = () => {
  const [cookie, setCookie] = useState(store.get(STORE_KEY));

  const handleOnAccept = useCallback(() => {
    store.set(STORE_KEY, true);
    setCookie(true);
  }, []);

  if (cookie) {
    return null;
  }

  return (
    <Container>
      <Items>
        <Item>
          {"🍪 When using this website you agree to be bound by our "}
          <a
            href={rootDomainUrl("/terms")}
            rel="noopener noreferrer"
            target="_blank"
          >
            terms
          </a>
        </Item>
        <Item>
          <Link
            data-cy="cookie-banner-btn"
            onClick={handleOnAccept}
            type="link"
          >
            Accept Terms
          </Link>
        </Item>
      </Items>
    </Container>
  );
};

export default CookieBanner;
